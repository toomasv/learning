Red [
	Purpose: {Example of scroller inside rich-text box}
]
context [
	rt: scr: i2: none
	select-line: function [line][
		pos: rt/text
		loop line - 1 [pos: find/tail pos newline]
		i1: index? pos
		if not i2: find next pos lf [i2: tail rt/text]
		i2: index? i2
		rt/data/1: as-pair i1 i2 - i1
	]
	view [
		rt: rich-text 100x150 "one^/two^/three^/four^/five^/six^/seven^/eight" 
		with [flags: 'scrollable] 
		on-created [
			put get-scroller face 'horizontal 'visible? no 
			scr: get-scroller face 'vertical 
			scr/max-size: rich-text/line-count? face
			scr/page-size: 1
			i2: index? find face/text newline 
			face/data: compose [(as-pair 1 i2) 255.255.255 backdrop 0.120.215 ]
		] 
		on-scroll [
			unless event/key = 'end [
				select-line scr/position: min max 1 switch event/key [
					track [event/picked]
					up page-up [scr/position - 1]
					down page-down [scr/position + 1]
				] scr/max-size
			]
		]
	]
]