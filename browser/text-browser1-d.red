Red [Needs: View]
view [
	below 
	field 400 on-enter [
		parse tx: write rejoin [face/data][
			get [Accept-Charset: "utf-8" User-Agent: "Mozilla/5.0"]
		] [some [remove [#"<" thru #">"] | skip]]
		ar/text: tx
	] 
	ar: area 400x400
]
