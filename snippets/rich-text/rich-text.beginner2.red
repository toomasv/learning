Red [
	Purpose: {Very simple rich-text demo}
]

rb: rtd-layout [i "And " /i b "another " /b red font 14 "example" /font]
view compose/deep [rich-text 200x50 draw [text 0x0 (rb)]]