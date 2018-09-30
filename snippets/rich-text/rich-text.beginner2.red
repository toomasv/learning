Red [
	Purpose: {Very simple multi-box rich-text demo}
]

rb1: rtd-layout [i "And " /i b "another " /b red font 14 "one" /font]
rb2: rtd-layout compose [i/b ["With "] font (system/view/fonts/fixed) "multi-box " /font blue font 18 "example" /font]
rb2/size: 200x50
view compose/deep [rich-text with [size: 500x100 draw: compose [text 5x0 (rb1) text 50x40 (rb2)]]]
