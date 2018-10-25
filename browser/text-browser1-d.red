Red [Needs: View]
view [
	below 
	field 400 on-enter [
		parse tx: read face/data [some [remove [#"<" thru #">"] | skip]]
		ar/text: tx
	] 
	ar: area 400x400
]
