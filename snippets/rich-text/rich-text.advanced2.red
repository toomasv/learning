Red [
  Author: "Toomas Vooglaid"
  Started: 2018-05-01
  Purpose: "First steps into rich-text box"
]
ctx: context [
	env: self
	start: end: 1 
	diff: 0
	dbl: no
	txt: p: l: style*:  none
	itext: copy []
	sep: charset { ,.!?:;"'`()[]{}/^-^M}
	found: found2: found3: dn?: none
	appendix: copy []
	
	bind colors: exclude sort extract load help-string tuple! 2 [glass] context [transparent: 0.0.0.254]
	pallette: [
		title "Select color" origin 1x1 space 1x1
		style clr: base 15x15 on-down [dn?: true] on-up [
			if dn? [env/color: face/extra unview]
		]
	]
	x: 0
	make-pallette: has [j][
		foreach j colors [
			append pallette compose/deep [
				clr (j) extra (to-lit-word j)
			]
			if (x: x + 1) % 9 = 0 [append pallette 'return]
		]
	]
	make-pallette
	color: black
	select-color: does [view/flags pallette [modal popup]]
	changing!: make typeset! [integer! string! tuple!]
	changing?: func [value [any-type!]][
		find changing! type? :value
	]
	set-style: func [face style /color clr][
		either face/data/1/y > 0 [
			either found: find next face/data face/data/1 [
				found2: find next found pair!
				style*: pick reduce [type? style style] changing? style
				found3: either found2 [find/part found style* found2][find found style*] 
				if all [style* = tuple! 'backdrop = found3/-1][found3: find next found3 tuple!]
				either found3 [
					either changing? style [
						change found3 style
					][
						either style = 'backdrop [
							change next found3 clr
						][
							remove found3
						]
					]
					if any [
						1 = length? found
						attempt [1 = offset? found find next found pair!]
					][
						remove found
					]
				][
					append clear appendix style
					if color [append appendix clr]
					either found2 [insert found2 appendix][append found appendix]
				]
			][
				append append clear appendix face/data/1 style
				if color [append appendix clr]
				append face/data appendix
			]
		][
			
		]
	]
	set-caret: func [face start /diff len /wheel][
		len: any [len 0] 
		face/data/1: as-pair start len
		either len > 0 [
			crt/visible?: no
			self/diff: len
		][
			crt/visible?: face/data/1/x > 0 [yes][no] 
			self/start: end: face/data/1/x
			self/diff: 0
			caret/2: caret-to-offset face start
			caret/3: as-pair caret/2/x second caret-to-offset/lower face start
			unless wheel [
				if caret/3/y > face/size/y [scroll face]
				if all [
					(caret/3/y - rich-text/line-height? face start) <= 0 
					1 < index? face/text
				][scroll/up face]
			]
		]
	]
	scroll: func [face /up /wheel /local latest][
		either up [; scroll up - text down
			attempt [
				latest: index? face/text
				face/text: at head face/text take itext
				set-markers face latest - index? face/text
				either wheel [
					set-caret/diff/wheel face face/data/1/x face/data/1/y
				][
					set-caret/diff face face/data/1/x face/data/1/y
				]
			]
		][; scroll down - text up
			unless itext/1 = index? face/text [insert itext index? face/text]
			face/text: at face/text offset-to-caret face as-pair 0 rich-text/line-height? face 1
			set-markers face itext/1 - index? face/text
			either wheel [
				set-caret/diff/wheel face face/data/1/x face/data/1/y
			][
				set-caret/diff face face/data/1/x face/data/1/y
			]
		]
		;probe head itext
		face/data: face/data
	]
	set-markers: func [face delta][
		parse face/data [some [s: pair! (s/1/x: s/1/x + delta) | skip]]
		start: start + delta end: end + delta
	]
	adjust-markers: func [face type len][
		switch type [
			key [
				parse next face/data [any [s: pair! (
					case [
						all [s/1/x + 1 < face/data/1/x s/1/x + s/1/y >= face/data/1/x][s/1/y: s/1/y - len + 1]
						s/1/x + 2 > face/data/1/x [s/1/x: s/1/x - len + 1]
					]
				) | skip]]
			]
			del [
				parse next face/data [any [s: pair! (
					len: either len > 0 [len][1]
					case [
						all [s/1/x <= face/data/1/x s/1/x + s/1/y > face/data/1/x][s/1/y: s/1/y - len]
						s/1/x + 2 > face/data/1/x [s/1/x: s/1/x - len]
					]
				) | skip]]
			]
			ins [
				parse next face/data [any [s: pair! (
					case [
						; marker containes selected text
						all [s/1/x + 1 < len/1 s/1/x + s/1/y >= (len/1 + len/2)][s/1/y: s/1/y - len/2 + len/3] 
						; selection starts before marker and ends inside marker
						all [s/1/x + 2 > len/1 s/1/x < (len/1 + len/2) s/1/x + s/1/y >= (len/1 + len/2)][s/1/x: face/data/1/x]
						; selection starts inside marker and ends after marker
						all [s/1/x + 1 < len/1 len/1 < (s/1/x + s/1/y) s/1/x + s/1/y < (len/1 + len/2)][s/1/y: face/data/1/x - len/3 - s/1/x]
						; selection lies before the marker
						s/1/x + 2 > len/1 [probe "hi" s/1/x: s/1/x - len/2 + len/3]
					]
				) | skip]]
			]
		]
	]
	view win: layout [
		title "Rich-text box"
		panel [
			origin 0x0
			space 5x0 
			style b: button 24x24 [
				set-style sb face/extra 
				win/selected: sb 
			]
			b "i" extra 'italic 
			b "b" extra 'bold 
			b "u" extra 'underline 
			b "s" extra 'strike
			base 24x24 225.225.225 draw [pen 170.170.170 box 0x0 23x23 pen red text 8x4 "T"][
				select-color 
				set-style sb get color  
			]
			base 24x24 225.225.225 draw [pen 170.170.170 fill-pen red box 0x0 23x23 pen black text 8x4 "T"][
				select-color 
				set-style/color sb 'backdrop get color  
			]
			drop-down select 2 40x24 
				data ["8" "9" "10" "11" "12" "14" "16" "18" "20" "22" "24" "36" "48"] 
				on-change [set-style sb to-integer pick face/data face/selected]
				on-enter [set-style sb to-integer face/text win/selected: sb]
			button "X" 24x24 [clear at sb/data 4]
		] return
		tp: panel [
			at 0x0 box white 320x220 ;draw [line 12x2 12x20]
			sb: rich-text 300x200 "" focus 
			cursor I-beam all-over
			with [data: [1x0 backdrop silver]]
			on-down [
				win/selected: face 
				either event/shift? [
					end: offset-to-caret face event/offset
					set-caret/diff face min start end absolute end - start
				][
					start: offset-to-caret face event/offset
				]
			] 
			on-over [
				if event/down? [
					end: offset-to-caret face event/offset
					set-caret/diff face min start end absolute end - start
				]
			]
			on-up [
				either dbl [dbl: no][
					end: offset-to-caret face event/offset 
					set-caret/diff face min start end absolute end - start
				]
			]
			on-dbl-click [
				start: either found: find/reverse at face/text offset-to-caret face event/offset sep [2 + (index? found) - index? face/text][1]
				end: either found: find next at face/text start sep [2 + (index? found) - index? face/text][1 + length? face/text]
				dbl: yes
				set-caret/diff face start end - start
			]
			on-wheel [
				either event/picked > 0 [scroll/up/wheel face][scroll/wheel face]
			]
			on-key [
				either event/ctrl? [
					switch event/key [ 
						#"^A" [set-caret/diff face 1 1 + length? face/text]
						#"^C" [if face/data/1/y > 0 [write-clipboard copy/part at face/text face/data/1/x face/data/1/y]]
						#"^X" [
							if face/data/1/y > 0 [
								write-clipboard copy/part at face/text face/data/1/x face/data/1/y 
								remove/part at face/text face/data/1/x len: face/data/1/y 
								set-caret face face/data/1/x
								adjust-markers face 'del len; Unfinished! Check overlapping regions
							]
						]
						#"^V" [
							change/part at face/text posx: face/data/1/x txt: read-clipboard len: face/data/1/y
							set-caret face face/data/1/x + length? txt
							adjust-markers face 'ins reduce [posx len length? txt]
						]
						#"^B" [set-style face 'bold]
						#"^I" [set-style face 'italic]
						#"^U" [set-style face 'underline]
						#"^S" [set-style face 'strike]
						left  [
							either event/shift? [
								either end > start  [
									end: either found: find/reverse back at face/text face/data/1/x + face/data/1/y sep [2 + (index? found) - index? face/text][1]
									set-caret/diff face min face/data/1/x end absolute end - face/data/1/x
								][
									set-caret/diff face end: either found: find/reverse back at face/text face/data/1/x sep [2 + (index? found) - index? face/text][1]
										face/data/1/x + face/data/1/y - end
								]
							][
								set-caret face either found: find/reverse back at face/text face/data/1/x sep [2 + (index? found) - index? face/text][1]
							]
						]
						right [
							either event/shift? [
								either end < start [
									end: either found: find next at face/text face/data/1/x sep [2 + (index? found) - index? face/text][1 + length? face/text]
									set-caret/diff face min start end absolute end - start
								][
									set-caret/diff face face/data/1/x 
										(end: either found: find next at face/text face/data/1/x + face/data/1/y sep [2 + (index? found) - index? face/text][1 + length? face/text]) - face/data/1/x
								]
							][
								set-caret face either found: find next at face/text face/data/1/x sep [2 + (index? found) - index? face/text][1 + length? face/text]]
							]
						#"^~" [
							remove/part at face/text end: either found: find/reverse back at face/text face/data/1/x sep [2 + (index? found) - index? face/text][1]
								(face/data/1/x - end)
							set-caret face end
						]
						delete [
							remove/part at face/text face/data/1/x 
								(either found: find next at face/text face/data/1/x sep 
									[2 + (index? found) - index? face/text][1 + length? face/text]) - face/data/1/x
							set-caret face face/data/1/x
						]
						end [
							either event/shift? [
								set-caret/diff face start (1 + length? face/text) - start
							][
								set-caret face 1 + length? face/text
							]
						]
						home [
							if 1 < index? face/text [start: start + index? face/text face/text: head face/text clear itext] 
							either event/shift? [
								set-caret/diff face 1 start - 1
							][
								set-caret face 1
							]
						]
						down [
							found: find next at face/text end #"^M"
							either event/shift? [
								either found [
									set-caret/diff face min start end: 2 + (index? found) - index? face/text absolute end - start
								][
									set-caret/diff face min start end: (length? face/text) absolute end - start + 1
								]
							][
								either found [set-caret face 2 + (index? found) - index? face/text][set-caret face 1 + length? face/text]
							]
						]
						up [
							found: find/reverse back at face/text end #"^M"
							unless found [if 1 < index? face/text [start: start + index? face/text face/text: head face/text clear itext]]
							either event/shift? [
								either found [
									set-caret/diff face min start end: 2 + (index? found) - index? face/text absolute end - start
								][
									set-caret/diff face end: 1 start - 1
								]
							][
								either found [set-caret face 2 + (index? found) - index? face/text][set-caret face 1]
							]
						]
					]
				][
					switch/default event/key [
						#"^H" [
							len: diff
							either diff > 0 [
								remove/part at face/text face/data/1/x face/data/1/y 1
							][
								remove at face/text face/data/1/x - 1
							]
							set-caret face face/data/1/x - pick [0 1] diff > 0
							adjust-markers face 'del len
						]
						delete [
							len: diff
							remove/part at face/text face/data/1/x pick reduce [face/data/1/y 1] diff > 0
							set-caret face face/data/1/x
							adjust-markers face 'del len
						]
						left [
							either event/shift? [
								end: end - 1
								set-caret/diff face min start end absolute end - start
							][
								set-caret face face/data/1/x - pick [0 1] diff > 0
							]
						]
						right [
							either event/shift? [
								end: end + 1
								set-caret/diff face min start end absolute end - start
							][
								set-caret face face/data/1/x + either 0 = face/data/1/y [1][face/data/1/y]
							]
						]
						down [
							p: caret-to-offset face end
							l: caret-to-offset/lower face end
							end: offset-to-caret face as-pair p/x l/y: l/y + 14
							either event/shift? [
								set-caret/diff face min start end absolute end - start
							][
								set-caret face end
							]
							if l/y > face/size/y [scroll face]
						]
						up [
							p: caret-to-offset face end
							l: caret-to-offset/lower face end 
							if all [1 < index? face/text l/y <= rich-text/line-height? face end][
								scroll/up face
							]; pooleli!
							end: offset-to-caret face as-pair p/x l/y - 1 - rich-text/line-height? face end 
							either event/shift? [
								set-caret/diff face min start end absolute end - start
							][
								set-caret face end
							]
						]
						end [
							end: offset-to-caret face as-pair face/size/x second caret-to-offset face start
							unless equal? second caret-to-offset face start second caret-to-offset face end [end: end - 1]
							either event/shift? [
								set-caret/diff face start end - start
							][
								set-caret face end
							]
						]
						home [
							end: offset-to-caret face as-pair 0 second caret-to-offset face start
							either event/shift? [
								set-caret/diff face end start - end
							][
								set-caret face end
							]
						]
					][
						change/part at face/text face/data/1/x event/key len: face/data/1/y
						set-caret face face/data/1/x + 1
						adjust-markers face 'key len
					]
				]
				face/data: face/data 
			]
			at 10x10 crt: box glass 300x200 rate 3 
			draw [pen black caret: line 0x1 0x16] 
			on-time [face/draw/2: pick [glass black] face/draw/2 = 'black]
		]
	]
]
