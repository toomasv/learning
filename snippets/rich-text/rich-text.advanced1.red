Red [
	Purpose: {A bit more advanced rich-text demo}
]

require: func [msg /font /color /size /local val][
	case/all [
		font [
			val: "System" 
			view compose [
				title (msg) 
				text-list 100x70 data ["System" system "Fixed" fixed "Serif" serif "Sans-serif" sans-serif] 
				select 1
				on-change [probe val: system/view/fonts/(pick face/data face/selected - 1 * 2 + 2) unview]
			]
		]
		size [
			val: 9
			view compose [
				title (msg) 
				drop-list data ["6" "7" "8" "9" "10" "12" "14" "16" "18" "20" "24" "28" "32"]
				select 4
				on-change [val: load pick face/data face/selected unview]
			]
		]
		color [
			val: 0.0.0
			view compose/only [
				title (msg) 
				drop-list data (split form exclude sort extract load help-string tuple! 2 [glass transparent] #" ")
				select 3
				on-change [val: get load pick face/data face/selected unview]
			]
		]
	]
	val
]
view compose [
	title "Area to rich-text" below 
	src: area wrap with [
		menu: ["Italic" italic "Bold" bold "Underline" underline "Strike" strike "Color" color "Backdrop" backdrop "Size" size "Font" font]
	] on-menu [
		spec: make block! 2 
		pos: as-pair face/selected/x face/selected/y - face/selected/x + 1 
		insert spec switch/default event/picked [
			backdrop [reduce ['backdrop require/color "Backdrop:"]] 
			color [reduce [require/color "Color:"]]
			size [reduce [require/size "Size:"]]
			font [reduce [require/font "Font:"]]
		][reduce [event/picked]]
		insert spec pos
		append rt/data spec
		probe rt/data
	] on-key [
		rt/text: face/text 
		rt/data: rt/data
	] return 
	pnl: panel white with [
		size: src/size 
		draw: compose [pen gray box 0x0 (size - 1)] 
		pane: layout/only compose [
			at 7x3 rt: rich-text (src/size - 10x6) with [
				data: copy []
			]
		]
	] button "Clear" [clear rt/data]
]