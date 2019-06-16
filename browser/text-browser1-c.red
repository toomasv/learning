Red [Needs: View]
view [
	below 
	field 400 on-enter [
		;ar/text: read face/data
		ar/text: write rejoin [face/data][
			get [Accept-Charset: "utf-8" User-Agent: "Mozilla/5.0"]
		]
	] 
	ar: area 400x400
]
