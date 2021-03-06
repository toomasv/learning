Red [Needs: View]
rule: [some [
	remove [
		"<script" thru "script>" 
	| 	"<style" thru "style>" 
	| 	#"<" thru #">"
	] 
| 	change "&nbsp;" #" "
| 	change "&amp;" #"&"
| 	change ["&#" s: to [e: #";"]] (to-char to-integer copy/part s e) 
| 	skip
]]
view [
	below 
	field 400 on-enter [
		parse tx: write rejoin [face/data][
			get [Accept-Charset: "utf-8" User-Agent: "Mozilla/5.0"]
		] rule
		ar/text: tx
	] 
	ar: area 400x400 wrap
]
