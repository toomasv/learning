Red []
F: ['line 0x-90 50x0 0x10 -40x0 0x30 30x0 0x10 -30x0 0x40]
view compose/deep [
	box 300x300 snow draw [
		fill-pen white 
		line 0x150 300x150 shape [move 300x150 'line -20x5 0x-10] text 280x155 "x"
		line 150x0 150x330 shape [move 150x300 'line 5x-20 -10x0] text 125x275 "y"
		; Translate
		translate 150x150 [matrix [1 0 0 1  0  0][fill-pen white shape [move 50x-30 (F)]]]
		translate 150x150 [matrix [1 0 0 1 20 20][fill-pen gold  shape [move 50x-30 (F)]]]
		; Scale
		translate 150x150 [matrix [1   0 0 1   0 0][fill-pen white shape [move -80x-30 (F)]]]
		translate 150x150 [matrix [1.2 0 0 1.2 0 0][fill-pen brick shape [move -80x-30 (F)]]]
		; Skew
		translate 150x150 [matrix [1 0 0 1 0 0]           [fill-pen white shape [move -80x120 (F)]]]
		translate 150x150 [matrix [1 0 (tangent 15) 1 0 0][fill-pen water shape [move -80x120 (F)]]]
		; Rotate
		translate 150x150 [matrix [1 0 0 1 0 0]                                           [fill-pen white shape [move 50x120 (F)]]]
		translate 150x150 [matrix [(cosine 15) (negate sine 15) (sine 15) (cosine 15) 0 0][fill-pen beige shape [move 50x120 (F)]]]	
	]
]
