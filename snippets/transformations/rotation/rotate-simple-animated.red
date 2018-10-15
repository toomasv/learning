Red []
t: 0 view [box 200x200 rate 10 draw [
    rotate 0 100x100 box 50x50 150x150
] on-time [face/draw/2: (t: t + 1) % 360]]