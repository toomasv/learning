# Building a browser

Let's make a browser, ... er ... micro-browser.
To qualify as browser it needs at least an address-bar and something like canvas or show-area, where data accessed from given address will be rendered.
So, let's make the [basic structure](text-browser1-a.red) stright away:
```
view [below field 400 area 400x400]
```
Next thing we need is giving our browser an address and fetching the data.
Address we we can write or paste into our field and the nice thing about the field is that it loads everything put into its `text` facet stright away into its `data` facet, so that if we enter a web address into field it is loaded at once into `data` facet as `url!`. Let's [try this](text-browser1-b.red) out reflecting the type into area using `on-enter` actor for this (we need to convert type-word into string to put it into area's `/text` facet):
```
view [
	below 
	field 400 on-enter [
		ar/text: to-string type?/word face/data
	] 
	ar: area 400x400
]
```
Yay! It works! We have our url-address!
Now we need actually to get something from this addrress. [Go and fetch it](text-browser1-c.red):
```
view [
	below 
	field 400 on-enter [
		ar/text: read face/data
	] 
	ar: area 400x400
]
```
That's it! We do have our browser fetching data from given address. But... we want more (or may-be less?) than html source. We want something readable or lookable by normal humans.

If we don't want to build full-fledged browser right now (we don't) we have to filter out what we don't want to see. So, most obviously, to read the text we need to get rid of tags. Let's go and [purge the tags](text-browser1-d.red):
```
view [
	below 
	field 400 on-enter [
		parse tx: read face/data [some [remove [#"<" thru #">"] | skip]]
		ar/text: tx
	] 
	ar: area 400x400
]
```
Now we have our text, but also script and style text from inside `<script>` and `<style>` tags. [Banish these too](text-browser1-e.red):
```
rule: [some [remove ["<script" thru "script>" | "<style" thru "style>" | #"<" thru #">"] | skip]]
view [
	below 
	field 400 on-enter [
		parse tx: read face/data rule
		ar/text: tx
	] 
	ar: area 400x400
]
```
Good! To improve readability we'd like to reduce white-space, [transform character-codes into characters and wrap lines](text-browser1-f.red):
```
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
		parse tx: read face/data rule
		ar/text: tx
	] 
	ar: area 400x400 wrap
]
```
To [reduce white-space](text-browser1-g.red) we'll have a second round of parse. First, define whitespace as charset, then remove exessive ws:
```
ws: charset reduce [space newline tab]
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
		parse tx: read face/data rule
		parse tx [some [2 newline change [newline some ws] newline | skip]]
		ar/text: tx
	] 
	ar: area 400x400 wrap
]
```
Nice and compact! There are few things more to improve. First, it would be nice to be positioned into address-field right on launching our browser. Second, we'd like to resize it. Third, we might to add site-specific parsing-rules to concentrate more on relevant parts.

First, [`focus` and `resize`](text-browser1-h.red), but on-resizing we need also take care of the size of our faces:
```
ws: charset reduce [space newline tab]
rule: [some [
	remove [
		"<script" thru "script>" 
	| 	"<style" thru "style>" 
	| 	#"<" thru #">"
	] 
| 	change "&nbsp;" #" "
| 	change "&amp;" #"&"
|	change ["&#" s: to [e: #";"]] (to-char to-integer copy/part s e) 
| 	skip
]]
view/flags [
	on-resizing [
		foreach-face face [
			either face/type = 'field [
				face/size/x: event/window/size/x - 20
			][
				face/size: event/window/size - face/offset - 10x10
			]
		]
	]
	below 
	field 400 focus on-enter [
		parse tx: read face/data rule
		parse tx [some [2 newline change [newline some ws] newline | skip]]
		ar/text: tx
	] 
	ar: area 400x400 wrap
] 'resize
```
Finally, we might add site-specific filters to concentrate more on [relevant content](text-browser1-i.red):
```
ws: charset reduce [space newline tab]
rule: [
	remove thru {<div class='blog-posts hfeed'>}
	some [
		remove [{<div class='blog-pager' id='blog-pager'>} thru end]
	|
		remove [
			"<script" thru "script>" 
		| 	"<style" thru "style>" 
		| 	#"<" thru #">"
		] 
	| 	change "&nbsp;" #" "
	| 	change "&amp;" #"&"
	|	change ["&#" s: to [e: #";"]] (to-char to-integer copy/part s e) 
	| 	skip
	]
]
view/flags [
	on-resizing [
		foreach-face face [
			either face/type = 'field [
				face/size/x: event/window/size/x - 20
			][
				face/size: event/window/size - face/offset - 10x10
			]
		]
	]
	below 
	field 400 default https://www.red-lang.org focus on-enter [
		parse tx: read face/data rule
		parse tx [some [2 newline change [newline some ws] newline | skip]]
		ar/text: tx
	] 
	ar: area 400x400 wrap
] 'resize
```

There are of-course many more things that might be included, rich-text formatting and links being first that pop into mind, but for primary level current text-browser is enough I think.
