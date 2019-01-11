Red []
lim: func [:z face][face/offset/:z + face/size/:z]
view/flags [
	on-resizing [
		pane: face/pane 
		max-y: 0
		max-x: 0 
		cur-y: 10
		forall pane [
			if 1 < length? pane [
				max-y: max max-y lim y pane/1
				max-x: max max-x lim x pane/1
				pane/2/offset: either face/size/x - pane/2/size/x - 20 < lim x pane/1 [
					max-x: 0
					as-pair 10 cur-y: max-y + 10
				][
					as-pair max-x + 10 cur-y 
				]
			]
		]
	] 
	base "base" field "field" area "area" text-list data ["text" "list"] text "Hola!" button "Button" tab-panel ["A" [] "B" []]
] 'resize