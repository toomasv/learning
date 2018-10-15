Red []
F: ['line 0x-90 50x0 0x10 -40x0 0x30 30x0 0x10 -30x0 0x40]
view/no-wait compose/deep [
	box 300x300 snow draw [
		fill-pen white 
		line 0x150 300x150 shape [move 300x150 'line -20x5 0x-10] text 280x155 "x"
		line 150x0 150x330 shape [move 150x300 'line 5x-20 -10x0] text 125x275 "y"
		; Original
		translate 150x150 [matrix [ 1 0 0  1 0 0][fill-pen white shape [move 50x-30 (F)]]]
		; Flip x
		translate 150x150 [matrix [-1 0 0  1 0 0][fill-pen gold  shape [move 50x-30 (F)]]]
		; Flip y
		translate 150x150 [matrix [ 1 0 0 -1 0 0][fill-pen brick shape [move 50x-30 (F)]]]
		; Flip both
		translate 150x150 [matrix [-1 0 0 -1 0 0][fill-pen water shape [move 50x-30 (F)]]]
	]
]
