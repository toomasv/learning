Red [
	Purpose: {Relatively simple rich-text demo}
	Help: {Select some text in first box, choose formatting from context-menu (alt-click).
		"Clear" clears formatting.}
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
	below src: area wrap with [
		menu: ["Italic" italic "Bold" bold "Underline" underline]
	] 
	on-menu [
		nls: count-nl face
		append rt/data reduce [
			as-pair face/selected/x - nls face/selected/y - face/selected/x + 1 event/picked
		]
	] 
	on-key [rt/text: face/text rt/data: rt/data] 
	return 
	pnl: panel white with [
		size: src/size 
		draw: compose [pen silver box 0x0 (size - 1)] 
		pane: layout/only compose [
			at 7x3 rt: rich-text with [
				size: src/size - 10x6 data: copy []
			]
		]
	] 
	button "Clear" [clear rt/data]
]
