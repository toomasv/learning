Red []
system/view/auto-sync?: off
context [
	cent: 10x10
	coef: -10
	rel: 1.0
	sides: [x y x]
	sz: side1: side2: prop: s1: none
	w: view/flags [
		;size 300x300
		size 530x320
		text-list 200x300 with [
			data: unique parse read https://en.wikipedia.org/wiki/Nature [collect [
				some [thru {thumb/} keep thru [{.jpg} | {.png} | {.gif}]]
			]]
			;collect [foreach f read %./ [if find [%.gif %.png %.jpeg %.jpg] suffix? f [keep f]]]
		]
		on-change [i/image: load to-url rejoin ["https://upload.wikimedia.org/wikipedia/commons/" pick face/data face/selected] show i]
		panel 300x300 [ 
			at 0x0 i: image https://upload.wikimedia.org/wikipedia/commons/b/bf/Aegopodium_podagraria1_ies.jpg
			;400x400 %red-logo-1.png ;%Monnier.jpg
			at 0x0 a: box 300x300
			at 220x220 b: base 0.0.0.240 80x80 with [
				pane: layout/only/tight [
					at 0x0 c: base 0.0.0.254 loose
						with [
							side1: pick [x y] i/size/x >= i/size/y
							side2: select sides side1 
							prop: 1.0 * i/size/:side2 / i/size/:side1
							
							size/:side1: to-integer 300.0 / i/size/:side1 * 80
							size/:side2: to-integer size/:side1 * prop
							draw: append append [box 0x0] sz: subtract as-pair size/x size/y 1 append [pen white box 1x1] sz
						]
						on-drag [
							face/offset/x: max 0 min b/size/x - face/size/x face/offset/x
							face/offset/y: max 0 min b/size/y - face/size/y face/offset/y
							i/offset: face/offset * coef ;+ cent
							show [face i]
						]
				] 
			] 
		]
	][resize]
]
comment {
}