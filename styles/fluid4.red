Red [
	Author: "Toomas Vooglaid"
	Date: 2018-10-11
	Last: 2018-10-18
	Purpose: {Fluid style for Red VID}
];#include %../../../utils/dump-face.red
;do %mylayout.red
system/view/auto-sync?: off
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
			to-integer either positive? ind [
				face/parent/size/:z * ind - pick [20 15] ind = 100%
			][
				face/parent/size/:z - (face/parent/size/:z * ind) - face/offset/:z
			]
		]
		integer! [either positive? ind [ind][face/parent/size/:z + ind - face/offset/:z]]
		block! [
			to-integer 1.0 * face/parent/size/:z - face/extra/space/:z / ind/2 * ind/1 - face/extra/space/:z
		]
	]
	either height [max as-pair width height face/extra/min][get-dims/height/sz face width sz-set?]
]
set-parent-size: func [face /height width /local dim z side limit ind][
	dim: pick [height width] height
	z: pick [y x] height
	side: pick [below right] height
	;probe reduce ["2" face/pane/1/type "width" width "height" height]
	set dim switch type?/word ind: face/extra/:dim [
		word! [
			switch ind [
				;auto [face/extra/space/:z + lim (z) face]
				fixed auto [
					any [
						all [
							empty? face/extra/:side
							max face/parent/size/:z face/extra/space/:z + lim (z) face
						]
						all [
							either 2 <= length? face/extra/:side [
								sort/compare face/extra/:side func [a b][(lim (z) a/1) > (lim (z) b/1)]
							][true]
							limit: lim (z) face/extra/:side/1/1 ;face/extra/:side/1/1/offset/:z + face/extra/:side/1/1/size/:z
							max face/parent/size/:z face/extra/space/:z + limit
						]
					]
				]
			]
		]
		percent! [
			to-integer either positive? ind [
				face/size/:z + (pick [20 15] ind = 100%) / ind
			][
				ind * face/parent/size/:z + face/size/:z
			]
		]
		integer! [
			either positive? ind [
				face/extra/:dim: face/size/:z
				max face/parent/size/:z face/extra/space/:z + lim (z) face
			][
				;print ["int" ind z]
				0 - ind + lim (z) face
			]
		]
		block! [
			to-integer face/size/:z + face/extra/space/:z * 1.0 / ind/1 * ind/2 + face/extra/space/:z
		]
	]
	;print ["1" face/pane/1/type "width" width "height" height]
	either height [face/parent/size: as-pair width height][set-parent-size/height face width]
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
	true ; probe ""
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
move-dependants: func [face /over /local right elem limit][
	if not empty? right: face/extra/right [
		foreach elem right [
			unless all [over attempt/safer [elem/1/extra/style = 'fluid]][
				limit: offset-left elem/1
				elem/1/offset/x: face/extra/space/x + max limit lim x face
			]
		]
	]
	if not empty? below: face/extra/below [
		foreach elem below [
			unless all [over attempt/safer [elem/1/extra/style = 'fluid]][
				limit: offset-above elem/1
				elem/1/offset/y: face/extra/space/y + max limit lim y face
			]
		]
	]
	true
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
extend system/view/VID/styles [
	fluid: [
		template: [
			type: 'panel 
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
				resize?: (no) ;TBD
				loose?: (no) ;TBD
			]
			actors: [
				pos: sz: diff: down?: none
				on-created: func [face event /local fc f] [
					unless face/parent/extra [face/parent/extra: copy []]
					append face/parent/extra face
					face/pane/1/offset: 0x0 ;1x1
					register-dependants face
					face/pane/1/size: face/size: get-dims face
					unless face/options/at-offset [
						face/offset: get-offset face
						move-dependants face
					]
					all [
						find [panel tab-panel] select fc: face/pane/1 'type
						fc/extra
						foreach f fc/extra [do-actor f event 'resizing]
					]
					all [
						any [face/extra/resize? face/extra/loose?]
						any [
							face/pane/1/actors 
							face/pane/1/actors: make object! []
						]
						face/pane/1/flags: 'all-over
						any [
							attempt/safer [:face/pane/1/actors/on-over]
							face/pane/1/actors: make face/pane/1/actors [
								on-over: func [face event][]
							]
						]
					]
				] 
				on-down: func [face event][
					all [
						face = event/face/parent
						face/extra
						any [
							all [
								face/extra/resize?
								within? event/offset face/pane/1/size - 20 20x20
								free-action: 'resize
								pos: event/offset
								diff: face/size - pos
							]
							all [
								face/extra/loose?
								free-action: 'loose
								pos: event/offset
							]
						]
					]
				]
				on-up: func [face event][
					pos: free-action: none
				]
				on-over: func [face event /local limit ind][
					all [
						face = event/face/parent
						event/down?
						pos
						any [
							all [
								free-action = 'resize
								face/size: face/pane/1/size: event/offset + diff
								register-dependants face
								move-dependants/over face
								set-parent-size face
							]
							all [
								free-action = 'loose
								diff: event/offset - pos
								face/offset: face/offset + diff
								;pos: event/offset
							]
						]
					]
					show face/parent
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
					show face/parent
				]
			]
		]
	]
]
view/flags [;
	size 300x275
	on-resizing [foreach f face/extra [do-actor f event 'resizing]]
	on-resize [foreach f face/extra [do-actor f event 'resizing]]
	;fluid with [extra/width: [1 3] extra/height: -50 extra/resize?: yes extra/loose?: yes][area wrap] 
	;fluid with [extra/height: 80% extra/width: 'fixed extra/resize?: yes extra/loose?: yes][bs: box gold] ;extra/absolute?: no
	;fluid with [extra/align: 'right][; extra/height: 'auto]
	;	text-list data [
	;		"Lorem" "ipsum" "dolor" "sit" "amet" "consectetur" "adipiscing" "elit" 
	;		"sed" "do" "eiusmod" "tempor" "incididunt" "ut labore" "et dolore" "magna" "aliqua"
	;	]
	;] 
	;return button "Longer button" [probe reduce [bs/flags bs/options]]
	
	;text "Description:" fluid with [extra/height: -120][area wrap] return ;
	;fluid with [extra/height: 25][panel [origin 0x0 text "First name:" fluid with [extra/space: 0x0][fn: field]]] return
	;fluid with [extra/height: 25][panel [origin 0x0 text "Last name:" fluid with [extra/space: 0x0][ln: field]]] return
	;fluid with [extra/size: 'fixed extra/valign: 'bottom extra/align: 'right][button "Send"];[panel [origin 0x0 field button "Send something" return base 80x40]]
	
	fluid with [extra/height: 'fixed][box brick] return
	fluid with [extra/width: 33% extra/height: -50][box leaf] 
	fluid with [extra/width: 15% extra/height: 50%][box gold] 
	;fluid with [extra/width: 15%][box teal] 
	fluid with [extra/width: 'auto extra/height: 'auto][box teal] 
	return button "OK"
	
	;fluid 300x300 [tab-panel ["A" [fluid [area]] "B" [fluid [field]]]]
][resize]