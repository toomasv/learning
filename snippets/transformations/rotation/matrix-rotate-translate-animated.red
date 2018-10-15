Red []
t: 0 view/tight [box 200x200 rate 10 draw [rotate 180 100x100 matrix [0 0 0 0 100 80] box -50x-50 50x50] 
    on-time [t: t + 1 
        face/draw/5/1: cosine t face/draw/5/2: negate sine t face/draw/5/3: sine t 
        face/draw/5/4: cosine t face/draw/5/6: face/draw/5/6 + 10 - (t % 21)
]]