Red []

clear-reactions
view [
	p: panel 366x200 [
		origin 0x0 space 0x0
		pan: panel 350x800 [
			origin 0x0 space 0x0
			style ar: area 350x200
			below
			ar "A" ar "B" ar "C" ar "D"
		] 
		box 17x200 draw [
			pen off fill-pen 200.200.200
			upper: box 0x0 16x16
			lower: box 0x184 16x199 
			fill-pen 220.220.220
			long: box 0x16 16x184
			fill-pen silver
			knob: box 1x16 14x58
		] on-up [
			either within? event/offset knob/2 knob/3 - knob/2 [
				face/extra: knob/2/y - event/offset/y
			][
				probe knob/2/y: val/data: min 142 max 16 knob/2/y + case [
					within? event/offset upper/2 upper/3 - upper/2 [-7]
					within? event/offset lower/2 lower/3 - lower/2 [7]
					within? event/offset long/2 knob/2 + 16x0 - long/2 [-42]
					within? event/offset knob/3 - 16x0 long/3 - (knob/3 - 16x0) [42]
				]
				probe knob/3/y: knob/2/y + 42
			]
		] all-over on-over [
			if all [within? event/offset knob/2 knob/3 - knob/2 event/down?][
				knob/2/y: val/data: min 142 max 16 event/offset/y + face/extra
				knob/3/y: knob/2/y + 42
			] 
		]
	]
	at 0x0 val: field "0" hidden
	react later [pan/offset/y: negate to-integer face/data - 16 * 1.0 / 168 * 800]
]
