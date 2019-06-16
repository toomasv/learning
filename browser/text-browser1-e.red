Red [Needs: View]
rule: [some [remove ["<script" thru "script>" | "<style" thru "style>" | #"<" thru #">"] | skip]]
view [
	below 
	field 400 on-enter [
		parse tx: write rejoin [face/data][
			get [Accept-Charset: "utf-8" User-Agent: "Mozilla/5.0"]
		] rule
		ar/text: tx
	] 
	ar: area 400x400
]
