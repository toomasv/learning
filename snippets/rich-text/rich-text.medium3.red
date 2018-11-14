Red [
	Purpose: {A bit more advanced rich-text demo}
	Help: {Select some text in first box, choose formatting from context-menu (alt-click).
		"Clear" clears formatting.}
]

require: func [msg /local val][
	switch msg [
		"Font:" [
			val: "System" 
			view compose [
				title (msg) 
				text-list focus 100x70 data ["System" system "Fixed" fixed "Serif" serif "Sans-serif" sans-serif] 
				select 1
				on-change [val: system/view/fonts/(pick face/data face/selected - 1 * 2 + 2) unview]
				on-dbl-click [val: system/view/fonts/(pick face/data face/selected - 1 * 2 + 2) unview]
			]
		]
		"Size:" [
			val: 9
			view compose [
				title (msg) 
				text-list focus data ["6" "7" "8" "9" "10" "12" "14" "16" "18" "20" "24" "28" "32"]
				select 4
				on-change [val: load pick face/data face/selected unview]
				on-dbl-click [val: load pick face/data face/selected unview]
			]
		]
		"Color:" "Backdrop:"[
			val: 0.0.0
			view compose/only [
				title (msg) 
				text-list focus data (split form exclude sort extract load help-string tuple! 2 [glass transparent] #" ")
				select 3
				on-change [val: get load pick face/data face/selected unview]
				on-dbl-clik [val: get load pick face/data face/selected unview]
			]
		]
	]
	val
]
count-nl: func [face /local text n x][
	n: 0 x: face/selected/x
	text: copy face/text
	while [all [
		text: find/tail text #"^/" 
		x >= index? text
	]][
		n: n + 1
	] n
]
view compose [
	title "Area to rich-text" below 
	src: area wrap with [
		menu: ["Italic" italic "Bold" bold "Underline" underline "Strike" strike "Color" color "Backdrop" backdrop "Size" size "Font" font]
	] on-menu [
		spec: make block! 2 
		i: 0 x: 0
		nls: count-nl face
		parse face/text [(i: 0 x: 0) some [(i: i + 1) if (i < face/selected/x) | exit]]
		pos: as-pair face/selected/x - nls face/selected/y - face/selected/x + 1 
		insert spec switch/default event/picked [
			backdrop [reduce ['backdrop require "Backdrop:"]] 
			color [require "Color:"]
			size [require "Size:"]
			font [require "Font:"]
		][reduce [event/picked]]
		insert spec pos
		append rt/data spec
		;probe rt/data
	] on-key [
		rt/text: face/text 
		rt/data: rt/data
	] 
	return 
	pnl: panel white with [
		size: src/size 
		draw: compose [pen gray box 0x0 (size - 1)] 
		pane: layout/only compose [
			at 7x3 rt: rich-text (src/size - 10x6) with [
				data: copy []
			]
		]
	] button "Clear" [clear rt/data]
	do [selected: src]
]