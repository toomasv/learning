Red [
	Author: "Toomas Vooglaid"
	Date: 2018-10-11
	Last: 2018-10-15
	Purpose: {Fluid style for Red VID}
];#include %../../../utils/dump-face.red
;do %mylayout.red
lim: func [:dir face][face/offset/:dir + face/size/:dir] 
; Get offset of the fluid container
get-offset: func [face /local x-ofs y-ofs][
	switch face/extra/align [
		left [x-ofs: face/offset/x]
		right [
			either empty? face/extra/right [
				x-ofs: face/parent/size/x - face/extra/space/x - face/size/x
			][
				if 2 <= length? face/extra/right [
					sort/compare face/extra/right func [a b][a/1/offset/x < b/1/offset/x]
				]
				x-ofs: face/extra/right/1/x - face/extra/space/x - face/size/x
			]
		]
	]
	switch face/extra/valign [
		top [y-ofs: face/offset/y]
		bottom [
			either empty? face/extra/below [
				y-ofs: face/parent/size/y - face/extra/space/y - face/size/y
			][
				if 2 <= length? face/extra/below [
					sort/compare face/extra/below func [a b][a/1/offset/y < b/1/offset/y]
				]
				y-ofs: face/extra/below/1/y - face/extra/space/y - face/size/y
			]
		]
	]
	as-pair max  face/extra/space/x + offset-left face x-ofs max face/extra/space/y + offset-above face y-ofs
]
; Get size of the fluid container
get-dims: func [face /height width /sz sz-set? /local size dim z side ind][
	if all [size: face/extra/size not sz-set?] [
		switch/default type?/word size [
			pair! block! [
				face/extra/width: size/1
				face/extra/height: size/2
			]
		][
			face/extra/width: face/extra/height: size
		]
		sz-set?: yes
	]
	dim: pick [height width] height
	z: pick [y x] height
	side: pick [below right] height
	; Determine value from parameter indication
	;print [dim height] 
	set dim switch type?/word ind: face/extra/:dim [
		word! [
			switch ind [
				auto [
					switch/default face/pane/1/type [
						area base text panel tab-panel button [
							;either face/extra/absolute? [
								face/parent/size/:z - face/offset/:z - face/extra/space/:z
							;][
							;	get-limit face side
							;]
						]
						text-list drop-list [
							either z = 'y [
								;either face/extra/absolute? [
									face/parent/size/:z - face/offset/:z - face/extra/space/:z
								;][
								;	get-limit face side
								;]
							][
								face/pane/1/size/:z
							]
						]
					][
						either z = 'x [
							;either face/extra/absolute? [
								face/parent/size/:z - face/offset/:z - face/extra/space/:z
							;][
							;	get-limit face side
							;]
						][
							face/pane/1/size/:z
						]
					]
				]
				fixed [face/pane/1/size/:z]
			]
		]
		percent! [
			either positive? ind [
				to-integer face/parent/size/:z * ind - pick [20 15] ind = 100%
			][
				to-integer face/parent/size/:z - (face/parent/size/:z * ind) - face/offset/:z
			]
		]
		integer! [either positive? ind [ind][face/parent/size/:z + ind - face/offset/:z]]
		block! [
			to-integer 1.0 * face/parent/size/:z - face/extra/space/:z / ind/2 * ind/1 - face/extra/space/:z
		]
	]
	either height [max as-pair width height face/extra/min][get-dims/height/sz face width sz-set?]
]
; Register faces on right/above of the current one
register-dependants: func [face /local pane elem][
	pane: face/parent/pane
	clear face/extra/right
	clear face/extra/below
	forall pane [
		elem: pane/1
		unless all [
			;face/extra/width <> 'fixed
			elem/offset/x > lim x face 
			not elem/options/at-offset
			face/offset/y < lim y elem
			elem/offset/y < lim y face
			append/only face/extra/right pane
		][
			all [
				;face/extra/height <> 'fixed
				elem/offset/y > lim y face 
				not elem/options/at-offset
				face/offset/x < lim x elem
				elem/offset/x < lim x face
				append/only face/extra/below pane
			]
		]
	]
	probe ""
]
; Max y-limit of faces above current one
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
; Max x-limit of faces on left
offset-left: func [face /local elem offset current][
	offset: 0
	foreach elem face/parent/pane [
		all [
			face/offset/x > (current: lim x elem)
			not elem/options/at-offset
			face/offset/y < lim y elem
			elem/offset/y < lim y face
			offset: max offset current
		]
	]
	offset 
]
; Move faces on right/below current one to appropriate places
move-dependants: func [face /local right elem limit][
	if not empty? right: face/extra/right [
		foreach elem right [
			limit: offset-left elem/1
			elem/1/offset/x: face/extra/space/x + max limit lim x face
		]
	]
	if not empty? below: face/extra/below [
		foreach elem below [
			limit: offset-above elem/1
			elem/1/offset/y: face/extra/space/y + max limit lim y face
		]
	]
]
get-limit: func [face side /local dim][
	dim: pick [x y] side = 'right
	either empty? face/extra/:side [
		face/parent/size/:dim - face/extra/space/:dim
	][
		if 2 <= length? face/extra/:side [
			sort/compare face/extra/:side func [a b][a/1/offset/:dim < b/1/offset/:dim]
		]
		face/extra/:side/1/1/offset/:dim - face/extra/space/:dim
	]
]
view/flags [
	size 300x275
	on-resizing [foreach f face/extra [do-actor f event 'resizing]]
	on-resize [foreach f face/extra [do-actor f event 'resizing]]
	style fluid: panel with [
		extra: compose [
			style: fluid
			size: (none) ; Can be pair!, word! ('auto, 'fixed, TBD 'proportional), block! of length 2, containing integer!s, percent!s, word!s or block!s (see width, height)
			width: auto ; Can be integer (positive: exact width; negative: distance of right side from limit), percent! (also negative - as for integer), word! ('auto, 'fixed), block! of two positive integer!s (treated as ratio first/second)
			height: auto ; See above + for two-dimensional faces 'auto is max available space, for one-dimensional faces, 'auto is face's y-size
			;absolute?: (yes) ; TBD yes - calculations from window/panel size, no - calculations from available space
			right: [] ; list of faces on right
			below: [] ; list of faces belo
			align: left ; Can be word! ('left, 'right); TBD 'center, integer!, percent!, block!
			valign: top ; Can be word! ('top, 'bottom); TBD 'middle, integer!, percent, block!
			space: 10x10 ; records space in current environment
			min: 50x25 ; minimal dimensions of current element
			;max: none ; TBD optional max dimensions of current element
			;min-pos, max-pos ;TBD?
			free-size?: (no) ;TBD
		]
		actors: object [
			pos: sz: diff: down?: none
			on-created: func [face event /local fc f] [
				unless face/parent/extra [face/parent/extra: copy []]
				append face/parent/extra face
				face/pane/1/offset: 0x0 ;1x1
				register-dependants face
				unless face/options/at-offset [
					face/pane/1/size: face/size: get-dims face
					face/offset: get-offset face
					move-dependants face
				]
				all [
					find [panel tab-panel] select fc: face/pane/1 'type
					fc/extra
					foreach f fc/extra [do-actor f event 'resizing]
				]
				all [
					face/extra/free-size?
					any [
						face/pane/1/actors 
						face/pane/1/actors: make object! []
					]
					face/pane/1/flags: 'all-over
					face/pane/1/actors: make face/pane/1/actors [
						on-over: func [fc event][
							if event/down? [do-actor fc/parent event 'over]
						]
					]
				]
			] 
			on-down: func [face event][
				all [
					face = event/face/parent
					face/extra
					face/extra/free-size?
					pos: event/offset
					diff: face/size - pos
				]
			]
			on-over: func [face event][
				all [
					face = event/face/parent
					face/extra/free-size?
					event/down?
					face/size: face/pane/1/size: event/offset + diff
					register-dependants face
					all [
						any [
							all [
								empty? face/extra/right 
								face/parent/size/x: max face/parent/size/x face/offset/x + face/size/x + face/extra/space/x
							]
							all [
								sort/compare face/extra/right func [a b][(lim x a/1) > (lim x b/1)]
								face/parent/size/x: max face/parent/size/x (lim x face/extra/right/1/1) + face/extra/space/x
							]
						]
					]
					move-dependants face
					
				]
			]
			on-resizing: func [face event /local fc f] [
				unless face/options/at-offset [
					face/pane/1/size: face/size: get-dims face
					face/offset: get-offset face
					move-dependants face
				]
				all [
					find [panel tab-panel] select fc: face/pane/1 'type
					fc/extra
					foreach f fc/extra [do-actor f event 'resizing]
				]
			]
		]
	]
	fluid with [extra/width: [1 3] extra/height: -50 extra/free-size?: yes][area wrap] 
	fluid with [extra/height: 80% extra/width: 'fixed extra/free-size?: yes][box gold] ;extra/absolute?: no
	fluid with [extra/align: 'right][; extra/height: 'auto]
		text-list data [
			"Lorem" "ipsum" "dolor" "sit" "amet" "consectetur" "adipiscing" "elit" 
			"sed" "do" "eiusmod" "tempor" "incididunt" "ut labore" "et dolore" "magna" "aliqua"
		]
	] 
	return button "Longer button"
	
	;text "Description:" fluid with [extra/height: -220][area wrap] return ;
	;fluid with [extra/height: 25][panel [origin 0x0 text "First name:" fluid with [extra/space: 0x0][fn: field]]] return
	;fluid with [extra/height: 25][panel [origin 0x0 text "Last name:" fluid with [extra/space: 0x0][ln: field]]] return
	;fluid with [extra/size: 'fixed extra/valign: 'bottom extra/align: 'right][button "Send"];[panel [origin 0x0 field button "Send something" return base 80x40]]
	
	;fluid with [extra/height: 'fixed][box brick] return
	;fluid with [extra/width: 33% extra/height: -50][box leaf] 
	;fluid with [extra/width: 15% extra/height: 50%][box gold] 
	;;fluid with [extra/width: 15%][box teal] 
	;fluid with [extra/width: 'auto extra/height: 'auto][box teal] 
	;return button "OK"
	
	;fluid 300x300 [tab-panel ["A" [fluid [area]] "B" [fluid [field]]]]
][resize]
