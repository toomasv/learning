Red []
clear-reactions
view [
	p: panel 370x200 [
		origin 0x0 space 0x0
		pan: panel 350x800 [
			origin 0x0 space 0x0
			style ar: area 350x200
			below
			ar "A" ar "B" ar "C" ar "D"
		]
		pad 1x-1
		panel 17x200 [
			origin 0x0 space 0x-1
			below
			button 17x16 [knob/offset/y: val/data: min 126 max 0 knob/offset/y - 7]
			base 220.220.220 17x168 with [
				pane: layout/only compose [
					at 1x0 knob: box silver loose (as-pair 15 168 / 4)
					on-drag [face/offset: as-pair 1 val/data: min 126 max 0 face/offset/y]
				]
			] on-down [
				knob/offset/y: val/data: min 126 max 0 knob/offset/y + pick [-42 42] event/offset/y < knob/offset/y
			]
			pad 0x-1
			button 17x16 [knob/offset/y: val/data: min 126 max 0 knob/offset/y + 7]
		]
	]
	at 0x0 val: field "0" hidden
	react later [pan/offset/y: negate to-integer face/data * 1.0 / 168 * 800]
]
