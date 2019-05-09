Red [
	Description: "Toggle button"
	Date: 2019-05-08
	Author: "Toomas Vooglaid"
]
context [
	make-transparent: function [img alpha][ ; Works on Windows, but not on Mac?
		tr: copy at enbase/base to-binary alpha 16 7
		append/dup tr tr to-integer log-2 length? img
		append tr copy/part tr 2 * (length? img) - length? tr
		make image! reduce [img/size img/rgb debase/base tr 16]
	]
	true-size: false-size: max-size: btn-size: box-size: ofs: crnr: none
	toggle-font: make font! [color: white style: 'bold]
	toggle-text: make face! [type: 'field font: toggle-font size: 200x25]
	corner: 'auto
	min-size: 50x25
	background: 'snow ; false ; `false` is for transparent background; 
		;if transparency doesn't work, use appropriate bg-color, usually `snow`
	extend system/view/VID/styles [
		toggle: [
			template: [
				type: 'base
				data: false
				extra: [
					text ["Yes" "No"]
					image []
				]
				actors: [
					on-down: func [face][
						face/data: not face/data 
						face/image: pick face/extra/image face/data
					]
				]
			]
			init: [
				true-size: size-text/with toggle-text face/extra/text/1
				false-size: size-text/with toggle-text face/extra/text/2
				max-size: 20x2 + max true-size false-size
				btn-size: max min-size max-size
				box-size: (face/size: btn-size) - 1
				either background [
					append face/extra/image draw btn-size compose [fill-pen (background) pen off box 0x0 (box-size)]
				][
					append face/extra/image make-transparent draw btn-size [] 255 
				]
				append face/extra/image copy face/extra/image/1
				ofs: btn-size - true-size / 2
				face/extra/image/1: draw face/extra/image/1 compose [
					fill-pen leaf pen gray box 0x0 (box-size) 
					(crnr: either corner = 'auto [box-size/y / 2][corner]) 
					font toggle-font text (ofs) (face/extra/text/1)
				]
				ofs: btn-size - false-size / 2
				face/extra/image/2: draw face/extra/image/2 compose [
					fill-pen brick pen gray box 0x0 (box-size) (crnr) font toggle-font text (ofs) (face/extra/text/2)
				]
				face/image: pick face/extra/image face/data
			]
		]
	]
]

comment {
	view [toggle]
	view [toggle with [extra/text: ["On" "Off"]]]
	view [toggle with [extra/text/1: "Supercali-^/fragilistic"]]
	view [toggle data true]
	view [t1: toggle toggle with [extra/text: ["True" "False"]] on-up [t1/actors/on-down t1]]
}