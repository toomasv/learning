Red [Needs: View]
thumbs: copy []
pos: none
view/flags [
	title "Wiki-Picky"
	size 1000x800 
	on-resizing [
		addr/size/x: face/size/x - 20
		sz/size/y: pics/size/y: face/size/y - 55
	]
	addr: drop-down 800 focus data [
		"https://en.wikipedia.org/wiki/Art"
		"https://en.wikipedia.org/wiki/Renaissance_art"
		"https://en.wikipedia.org/wiki/Modern_art"
		"https://en.wikipedia.org/wiki/Classical_art"
		"https://en.wikipedia.org/wiki/Medieval_art"
		"https://en.wikipedia.org/wiki/Mathematics_and_art"
		"https://en.wikipedia.org/wiki/Chinese_Art"
		"https://en.wikipedia.org/wiki/Celtic_art"
		"https://en.wikipedia.org/wiki/Czech_art"
		"https://en.wikipedia.org/wiki/French_art"
		"https://en.wikipedia.org/wiki/German_art"
		"https://en.wikipedia.org/wiki/Japanese_art"
		"https://en.wikipedia.org/wiki/Russian_Art"
	] on-enter [
		unless empty? face/text [
			clear thumbs 
			unless find face/data face/text [insert face/data face/text]
			parse read to-url face/text [
				collect into thumbs [some [
					to {class="thumbimage"}
					thru {src="} 
					keep to {"} 
				| 	thru end
				]]
			] 
			forall thumbs [thumbs/1: append copy https:// skip thumbs/1 2]
			append clear pics/data collect [
				forall thumbs [
					keep copy find/last/tail thumbs/1 #"/"
				]
			]
			pics/selected: 1
			show pics
		]
	] on-select [face/actors/on-enter face event] 
	return 
	pics: text-list 200x745 data [] on-change [
		img/image: load thumbs/(face/selected) 
		img/size: img/image/size
	] 
	at 208x45 sz: box 0.0.0.254
		with [size: as-pair 5 pics/size/y]
		on-down [pos: event/offset/x]
		all-over on-over [
			if pos [
				diff: event/offset/x - pos
				face/offset/x: face/offset/x + diff
				pics/size/x: pics/size/x + diff
				img/offset/x: img/offset/x + diff
			]
		]
		on-up [pos: none]
	img: image 100x100
] 'resize

