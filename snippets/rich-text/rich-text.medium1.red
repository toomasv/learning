Red [
	Purpose: {Relatively simple rich-text demo}
	Help: {Enter text. Select some text, choose formatting from contextual menu (alt-click).
		Press "View" to see formatting, "Text" to return to text editing, "Clear" to clear formatting.}
]
view compose [
	src: area wrap with [
		menu: ["Italic" italic "Bold" bold "Underline" underline]
	] on-menu [
		append rt/data reduce [
			as-pair face/selected/x face/selected/y - face/selected/x + 1 event/picked
		]
	] at 16x12 rt: rich-text hidden with [
		data: copy [] 
		size: src/size - 7x3
	] below button "View" [
		if show-rt: face/text = "View" [rt/text: copy src/text] 
		face/text: pick ["Text" "View"] rt/visible?: show-rt
	] button "Clear" [clear rt/data]
]

