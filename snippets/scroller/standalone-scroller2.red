Red [
	Title: {Example of stand-alone scroller}
]
view [
    size 390x220
    across space 0x0
    panel 350x200 [
        origin 0x0 space 0x0
        p: panel 350x800 [
            origin 0x0 space 0x0
            below
            area "A" 350x200
            area "B" 350x200
            area "C" 350x200
            area "D" 350x200
        ]
    ]
    sc: scroller 16x200 [
        face/data: min .75 face/data
        p/offset/y: to integer! negate 800 * face/data
    ] 
    on-created [face/selected: 25%]
]

