Red [
	Author: "Toomas Vooglaid"
	Date: 2018-10-09
	Purpose: {Study of shrinkable panels}
]
context [
	; Simple helper to get extension limit of a face
	lim: func [:dir face][face/offset/:dir + face/size/:dir] 
	; Set height of the face and draw its border
	set-height: func [face /shrunk /local height fc][
		face/size/y: either shrunk [10][
			height: 0 
			foreach fc face/pane [height: max height lim y fc] 
			height + 10 
		]
		face/draw/3: face/size - 1
	]
	; Collect pointers to faces affected by height of current face
	register-followers: func [face /local pane elem][
		pane: face/parent/pane
		clear face/extra/below
		forall pane [
			elem: pane/1
			all [
				elem/offset/y > face/offset/y 
				not elem/options/at-offset
				face/offset/x < lim x elem
				elem/offset/x < lim x face
				append/only face/extra/below pane
			]
		]
	]
	; Find furthest-extending face above current one
	offset-above: func [face /local elem offset current][
		offset: 0
		foreach elem face/parent/pane [
			all [
				face/offset/y > (current: lim y elem)
				not elem/options/at-offset
				face/offset/x < lim x elem
				elem/offset/x < lim x face
				offset: max offset current
			]
		]
		offset
	]
	; Move facese below current one to appropriate places
	move-followers: func [face /local below closest limit elem][
		if not empty? below: face/extra/below [
			foreach elem below [
				limit: offset-above elem/1
				elem/1/offset/y: 10 + max limit lim y face
			]
		]
	]
	view [
		style shrink: panel draw [box 0x0 0x0] with [
			; Some parameters specific for shrinkable style
			extra: compose [style: shrink expand?: (yes) below: []] 
			actors: object [
				on-created: func [face event][
					; First, register those below current face, affected by its height
					register-followers face
					; Then, set proper height of the face
					either face/extra/expand? [
						set-height face
					][
						set-height/shrunk face
					]
					; Finally, adjust offsets of those below
					move-followers face
				]
				; `on-down` follows basically same logic as `on-created`
				on-down: func [face event][
					register-followers face
					; If this is the face that got event...
					either face = event/face [
						either face/extra/expand?: not face/extra/expand? [
							set-height face
						][
							set-height/shrunk face
						]
					][
						; ... otherwise it is shrinkable parent - adjust its height
						set-height face
					]
					move-followers face
				] 
			]
		] 
		; Demo layout
		shrink with [extra/expand?: yes][
			shrink with [extra/expand?: no][
				base 80x100 red area below field button "Btn"
			] 
			shrink loose [base green] 
			return 
			shrink with [extra/expand?: no][
				base 80x80 gold shrink [below field button area]
			] 
			text "Wunderbar"
		]
		return
		base water
	]
]