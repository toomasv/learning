Red [
	Purpose: {Example of stand-alone scroller}
]
view [
	sc: scroller 15x150 [tl/selected: to-integer round/ceiling face/data / face/steps] 
	on-created [
		face/steps: 1.0 / len: length? tl/data 
		face/selected: 1.0 / len * 100%]
	tl: text-list 100x150 data [
		"one" "two" "three" "four" "five" "seven" "eight" "nine"
	]
]
