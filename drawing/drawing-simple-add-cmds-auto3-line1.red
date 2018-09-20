Red []
context [
	commands: [
		{line 0x0 0x0}
		{spline 0x0 0x0}
		{box 0x0 0x0 0}
		{ellipse 0x0 0x0}
		{circle 0x0 0}
		{triangle 0x0 0x0 0x0}
		{polygon 0x0 0x0 0x0}
		{arc 0x0 0x0 0 0}
		{curve 0x0 0x0 0x0 0x0}
		{text 0x0 "text"}
		{none}
		{pen black}
		{fill-pen white}
		{line-width 1}
		{line-join miter}
		{line-cap flat}
		{anti-alias on}		
	]
	view/no-wait [
		text "Clik on command, edit it and press enter:" return
		cmd: field 360 focus [append canvas/draw face/data clear face/text] 
		button "Clear" 40 [clear canvas/draw] return
		tl: text-list 100x300 data [
			"line" "spline" "box" "ellipse" "circle" "triangle" "polygon" "arc" "curve" "text" 
			"---" "pen" "fill-pen" "line-width" "line-join" "line-cap" "anti-alias"
		] on-change [cmd/text: pick commands face/selected step: 0]
		canvas: box 300x300 white draw []
		on-down [
			switch shape: pick tl/data tl/selected [
				"line" [
					either step = 0 [
						s: skip insert tail face/draw compose [
							line (o: event/offset) (o)
						] -3
					][
						s: insert tail face/draw event/offset
					] step: step + 1
				]
				"box" [s: skip insert tail face/draw compose [box (o: event/offset) (o)] -3]
			]
		]
		all-over
		on-over [
			if event/down? [
				switch shape [
					"line" [either step = 1 [s/3: event/offset][s/-1: event/offset]]
					"box" [s/2: min event/offset s/2 s/3: max event/offset s/3]
				]
			]
		]
		on-up [
			
		]
	]
]