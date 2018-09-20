**Let's build a little drawing program**

To build a drawing program you need foremost to know how to use drawing commands. 
Let us then first gain some experience by playing with drawing commands. 
For this you can use the following simpliest drawing application. 
You may need to look up which drawing commands are available and also consult 
their syntax at [Draw dialect reference document](https://doc.red-lang.org/en/draw.html).
While I recommend studying these documents, you may also go on with this tutorial
and we'll cover basics in the process. For starter, here is your [basic drawing program](drawing-simple.red):

```
Red []
view [
	below 
	text "Write some drawing commands here and press enter:"
	field 300 focus	[append clear canvas/draw face/data] 
	canvas: box 300x300 white draw []
]
```

To understand what is going on here and how to build simple GUI-s you may look at [another tutorial
covering VID's basics](<not-ready-yet>).

Now back to our drawing-app. In a way this app is already a complete drawing program as you can write the complete 
picture stacking commands on the the field. But it is cumbersome to use for anything but simple short commands. 

To build the drawing incrementally we might want to add results of individual commands to canvas. 
You can do it by changing field's behaviour: via [this ajusted app](drawing-simple-add.red). 

```
field 300 focus	[append canvas/draw face/data clear face/text] 
```

While we can add figures now incrementally, we lost the capacity to clean our canvas. To start afres 
we have to close and reopen our app. Not nice. Let's add [clearing button behind the field](drawing-simple-add-clear.red):

```
Red []
view [
	text "Write some drawing commands here and press enter:" return
	field 350 focus [append canvas/draw face/data clear face/text] 
	button "Clear" 40 [clear canvas/draw] return
	canvas: box 400x400 white draw []
]
```

Notice, that we have restructured the flow of faces somewhat to take advantage of the automatic placement.
Well, now we can add all kind of figures and formatting and even transformations to our canvas, if... if only we knew the syntax.
And even if we might learn it (we have to!) we can't expect that people for who's delight we are making this app, will learn it.
Hey, we are trying to make life easier here. So, let's invent something. Let's e.g. prepare commands with syntax, so we don't have to
look up docs all the time. Here we go with a selection of commands:

```
commands: [
	{line 0x0 0x0}
	{spline 0x0 0x0}
	{box 0x0 0x0 0}
	{ellipse 0x0 0x0}
	{circle 0x0 0}
	{triangle 0x0 0x0 0x0}
	{polygon 0x0 0x0 0x0}
	{arc 0x0 0x0 0 0}
	{curve 0x0 0x0 0x0 0x0}
	{text 0x0 "text"}
	{none}
	{pen black}
	{fill-pen white}
	{line-width 1}
	{line-join miter}
	{line-cap flat}
	{anti-alias on}		
]
```

For the time being I left out transformation commands and shape commands to keep it simple. But we'll tackle these later.
If you look at these commands you'll notice {none} in second half. This will separate drawing commands proper from formatting commands.
Now we need an element in our VID which will let us choose these commands so that chosen command is pasted into the field where
we can edit it. Let's use `text-list` for this purpose, adding it after the button "Clear", before the canvas, on left side:

```
button "Clear" 40 [clear canvas/draw] return
tl: text-list 100x300 data [
	"line" "spline" "box" "ellipse" "circle" "triangle" "polygon" "arc" "curve" "text" 
	"---" "pen" "fill-pen" "line-width" "line-join" "line-cap" "anti-alias"
]
canvas: box 300x300 white draw []
```

Now we have list of commands in our GUI, bunch of commands with sytnax, and a field but we need them to interact with each other. 
First we need to give our elements names, so we can refer to them. Let's name list of commands with syntax `commands`, text-list `tl`
and editable field `cmd`. Then we need to connect these together by a formula. We can use text-list's `on-change` actor for that:

``` 
on-change [cmd/text: pick commands face/selected]
```

We'll also wrap our code into `context` to keep it separated from global environment. 
Putting all these elements together we have [following code](drawing-simple-add-cmds.red):

```
Red []
context [
	commands: [
		{line 0x0 0x0}
		{spline 0x0 0x0}
		{box 0x0 0x0 0}
		{ellipse 0x0 0x0}
		{circle 0x0 0}
		{triangle 0x0 0x0 0x0}
		{polygon 0x0 0x0 0x0}
		{arc 0x0 0x0 0 0}
		{curve 0x0 0x0 0x0 0x0}
		{text 0x0 "text"}
		{none}
		{pen black}
		{fill-pen white}
		{line-width 1}
		{line-join miter}
		{line-cap flat}
		{anti-alias on}		
	]
	view/no-wait [
		text "Clik on command, edit it and press enter:" return
		cmd: field 360 focus [append canvas/draw face/data clear face/text] 
		button "Clear" 40 [clear canvas/draw] return
		tl: text-list 100x300 data [
			"line" "spline" "box" "ellipse" "circle" "triangle" "polygon" "arc" "curve" "text" 
			"---" "pen" "fill-pen" "line-width" "line-join" "line-cap" "anti-alias"
		] on-change [cmd/text: pick commands face/selected]
		canvas: box 300x300 white draw []
	]
]
```

So far so good. But let's go on to make our drawing 
program more like hmm.. drawing on canvas. Let's actually draw on it.

**Drawing a box**

To achieve this we have to use some actors. First, we need to register where does mouse touch our canvas on 
left-down event and then we have to track its movement while it's kept down. 

To register the first push we'll use event `down`, which is caught by actor `on-down`. Let's try it first on `box`.
So, on mouse's `down` event we insert box's formula with both starting-point and ending-point set to `event/offset` coordinates:

```
on-down [insert tail face/draw compose [box (event/offset) (event/offset)]]
```

To be able to manipulate box's coordinates on moving of mouse we need a "handle". We might use `back tail face/draw` to position
ourselves right before box's second coordinate, but it would be more universal and convenient to set our handle just before
the box formula:

```
on-down [s: skip insert tail face/draw compose [box (event/offset) (event/offset)] -3]
```

Here we are first composing box's formula with `down` event's offset. Then we are inserting this formula to the tail of `face/draw`, i.e. our canvas.
And finally we are skipping 3 steps back from tail (to just before `box`) and recording this position with set-word `s:`.

But in this way any `down` event regadless of which figure is selected on text-list will result in inserting box. 
We need to discriminate between which figure is selected, and insert different formulas accordingly.
Let's handle this by switchig on selected element. `tl/selected` gives us the number of selected element in tl (i.e. our textlist), 
so we neede to pick corresponding elemnt from `tl/data`:

```
on-down [
	switch pick tl/data tl/selected [
		"box" [s: skip insert tail face/draw compose [box (event/offset) (event/offset)] -3]
	]
]
```

OK. We have set our initial position, now we need to expand the box by pulling mouse across canvas. We'll catch this movement with actor `on-over`.
By default `on-over` catches only movement into and out-of face. To catch all movements of mouse over our canvas we need to add `all-over` keyword to our VID.
We know that `s` is our handle to access elements in `box`'s formula, and we need to set third element in this formula to the moving `event/offset`:

```
all-over
on-over [s/3: event/offset]
```

Oops! This has two flaws: 1) again, we didn't specify we need to set `s/3` when `box` figure is selected, and 2) currently it captures all mouse movements over canvas
but we need to capture these movements only if left-button is down. Let's correct it:

```
all-over
on-over [if event/down? [switch pick tl/data tl/selected ["box" [s/3: event/offset]]]]
```

Finally, let's rationalize our code a bit:
```
on-down [
	switch shape: pick tl/data tl/selected [
		"box" [s: skip insert tail face/draw compose [box (o: event/offset) (o)] -3]
	]
]
all-over
on-over [
	if event/down? [
		switch shape [
			"box" [s/3: event/offset]
		]
	]
]
```
