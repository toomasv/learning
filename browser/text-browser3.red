Red [Needs: View]
ctx: context [
	ws: charset reduce [space newline tab]
	qt: charset {"'}
	string-rule: [some [
		  remove [#"<" thru #">"]
		| change "&nbsp;" (" ") 
		| change "&amp;" ("&") 
		| change "&lt;" ("<")
		| change "&gt;" (">")
		| change ["&#" s: to [e: #";"]] (to-string to-char to-integer copy/part s e) 
		| change [some ws] (" ")
		| skip
	]]
	tag-end: [" " thru ">" | ">"]
	rt: make face! [type: 'rich-text]
	text-size: page-size: pages: lines-count: line-height: 0
	current: line: track-line: 1
	lines: make block! 1000
	anchors: make block! 100
	anch: 0
	scr: none
	scripts: copy []
	html2rt: [(anch: 0)
		collect [
			some [
				"<title" tag-end keep ("^/") keep (<font>) keep (16) | "</title>" keep (</font>) keep ("^/")
			|	"<h1" tag-end keep ("^/") keep (<font>) keep (16) | "</h1>" keep (</font>) keep ("^/")
			|	"<h2" tag-end keep ("^/") keep (<font>) keep (14) | "</h2>" keep (</font>) keep ("^/")
			|	"<h3" keep (<font>) keep (12) tag-end keep ("^/") | "</h3>" keep (</font>) keep ("^/")
			|	"<p" tag-end keep ("^/") | "</p>" keep ("^/")
			|	"<br" opt " " opt "/" ">" keep ("^/")
			|	ahead "<li" keep "^/"
			|	"<a " thru [{href=} | {name=}] qt 
				copy href to qt 
				thru #">" 
				copy an to "</a>" 
				(parse an string-rule) 
				[if (not empty? an) [if (find/match href "http")
				keep (<u>) keep ('blue) keep (an) keep (</u>) keep ('black)
				(append anchors reduce [anch: anch + 1 to-url href]) | keep (an)]|]
			|	"</a>"
			|	"<?red " copy red-script to "/>" (append/only scripts load red-script) "/>"
			|	"<head" thru "head>"
			|	"<script" thru "script>" 
			| 	"<style" thru "style>" 
			| 	#"<" thru #">"
			| 	copy st to ["<" | end] keep (
				parse st string-rule either empty? st [" "][st]
			)
			]
		]
	]
	sum-lines: func [start op count /local length][
		length: 0
		repeat i count [
			length: length op pick at lines start i
		]
		length
	]
	scroll: func [by /track /local op current i count start length][
		either track [
			either track-line <> by [
				line: by
				start: min line track-line
				count: absolute line - track-line
				by: line - track-line
				op: either positive? by [:+][:-]
				length: sum-lines start :op count
				rt/text: skip rt/text length
				track-line: line
			][length: 0]
		][
			if word? by [
				by: switch by [
					up [-1] down [1] 
					page-up [1 - page-size] page-down [page-size - 1]
					home [1 - line] end [lines-count - page-size - line + 1]
				]
			]
			current: line
			line: scr/position: min max line + by 1 lines-count
			start: min line current
			count: absolute line - current
			op: either positive? by [:+][:-] 
			length: sum-lines start :op count
			rt/text: skip rt/text length
		]
		;if length > 0 [
			parse rt/data [any [s: pair! (s/1/1: s/1/1 - length) | skip]]
			parse anchors [any [s: pair! (s/1/1: s/1/1 - length) | skip]]
			system/view/platform/redraw document
		;]
	]
	find-address: func [clk][
		foreach [range adr] anchors [
			if all [clk >= range/1 clk <= (range/1 + range/2)] [return adr]
		]
		none
	]
	go-to: func [address][
		clear anchors
		tx: case [
			any [
				find/match find/last/tail address #"." "css"
				find/match find/last/tail address #"." "red"
				find/match find/last/tail address #"." "txt"
				find/match find/last/tail address #"." "js"
			][
				append copy [] any [
					all [url? address read-thru/update address] 
					all [file? address read address]
				]
			]
			true [
				parse any [
					all [url? address read-thru/update address] 
					all [file? address read address]
				] html2rt
			]
		]
		;probe anchors
		addr/text: mold address
		rt: rtd-layout tx
		i: 0 
		foreach [adr frm] rt/data [
			if frm = 'underline [	
				i: i + 1 
				if found: find anchors i [
					change found adr
				]
			]
		]
		rt/size: lay/size - 30x65
		clear lines
		parse rt/text [
			(i: 0) 
			collect into lines some [ 
				(i: i + 1) 
				newline	keep (i)(i: 0) 
			| 	skip 
			]
		]
		;probe lines
		if i > 0 [append lines i]
		;text-size: size-text rt
		lines-count: scr/max-size: length? lines ;rich-text/line-count? rt
		;line-height: to-integer 1.0 * text-size/y / lines-count ; avgerage line height
		line-height: 16; rich-text/line-height? rt 1
		page-size: scr/page-size: rt/size/y / line-height
		document/draw: compose [text 5x5 (rt)]
		do [forall scripts [do scripts/1] system/view/platform/redraw document]
		set-focus document
	]
	view/flags lay: layout [
		on-resizing [
			foreach-face face [
				either face/type = 'field [
					face/size/x: event/window/size/x - 20
				][
					face/size: event/window/size - face/offset - 10x10
				]
				if attempt [rt][rt/size: face/size - 30x65]
			]
		]
		below 
		addr: field 600 default https://www.red-lang.org focus on-enter [
			go-to face/data
		] 
		across 
		document: rich-text 600x400 draw []
		with [
			flags: [scrollable all-over]
			actors: object [
				on-scroll: func [face event][
					switch/default event/key [
						track [scroll/track event/picked]
						end []
					][scroll event/key]
				]
				on-wheel: func [face event][
					by: pick [1 -1] negative? event/picked
					scroll either event/ctrl? [10 * by][by]
				]
				on-down: func [face event /local clk adr pos sum-lines len][
					clk: offset-to-caret rt event/offset
					if adr: find-address clk [go-to adr]
					;pos: as-pair 1 clk/y
					;sum-lines: 0
					;if pos > 1 [
					;	until [
					;		line: min line + 1 lines-count
					;		rt/text: skip rt/text len: lines/(line - 1)
					;		pos <= sum-lines: sum-lines + len
					;	]
					;]
					;scroll 0 - page-size / 2
				]
				ev-pos: none
				on-key: func [face event][
					if find [home end up down page-up page-down] event/key [
						scroll event/key
					]
				]
				on-mid-down: func [face event][
					face/rate: 4
					ev-pos: event/offset/y
				]
				on-time: func [face event][
					scroll either face/size/y / 2 < ev-pos [1][-1]
				]
				on-mid-up: func [face event][face/rate: none]
				on-created: func [face event][
					scr: get-scroller face 'horizontal
					scr/visible?: no
					scr: get-scroller face 'vertical
					line: scr/position: 1
				]
			]
		]
	] 'resize
]
