Red []
view [
	text "Write some drawing commands here and press enter:" return
	field 350 focus [append canvas/draw face/data clear face/text] 
	button "Clear" 40 [clear canvas/draw] return
	canvas: box 400x400 white draw []
]