Red [
	Description: "Toggle button"
	Date: 2019-05-08
	Author: "Toomas Vooglaid"
]
context [
	true-size: false-size: max-size: btn-size: box-size: ofx: none
	toggle-font: make font! [color: white style: 'bold]
	toggle-text: make face! [type: 'area font: toggle-font size: 200x25 text: copy ""]
	extend system/view/VID/styles [
		toggle: [
			template: [
				type: 'base
				size: 50x25
				default: false
				extra: [
					true "Yes" 
					false "No"
					true-img _ 
					false-img _
				]
				actors: [
					on-down: func [face][
						face/data: not face/data 
						face/image: get pick [face/extra/true-img face/extra/false-img] face/data
					]
				]
			]
			init: [
				true-size: size-text/with toggle-text face/extra/true
				false-size: size-text/with toggle-text face/extra/false
				max-size: 2 + max true-size false-size
				btn-size: max 50x26 max-size
				box-size: (face/size: btn-size) - 1
				face/extra/true-img: draw btn-size compose [fill-pen snow pen off box 0x0 (box-size)]
				face/extra/false-img: copy face/extra/true-img
				ofs: btn-size - true-size / 2
				face/extra/true-img: draw face/extra/true-img compose [
					fill-pen leaf pen gray box 0x0 (box-size) 12 font toggle-font text (as-pair ofs/x 1) (face/extra/true)
				]
				ofs: btn-size - false-size / 2
				face/extra/false-img: draw face/extra/false-img compose [
					fill-pen brick pen gray box 0x0 (box-size) 12 font toggle-font text (as-pair ofs/x 1) (face/extra/false)
				]
				face/data: face/default
				face/image: get pick [face/extra/true-img face/extra/false-img] face/data
			]
		]
	]
]
