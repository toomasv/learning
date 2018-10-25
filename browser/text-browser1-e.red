Red [Needs: View]
rule: [some [remove ["<script" thru "script>" | "<style" thru "style>" | #"<" thru #">"] | skip]]
view [
	below 
	field 400 on-enter [
		parse tx: read face/data rule
		ar/text: tx
	] 
	ar: area 400x400
]
