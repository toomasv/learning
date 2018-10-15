Red []
t: 0 view [box 200x200 rate 10 draw [matrix [0 0 0 0 100 100] box -50x-50 50x50] 
    on-time [t: t + 1 
        face/draw/2/1: .5 * cosine t face/draw/2/2: negate sine t 
        face/draw/2/3: sine t face/draw/2/4: 1.5 * cosine t
]]