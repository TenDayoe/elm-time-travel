# Part 2: Build a time machine

## Step 2: Save history

Our goal in this step is to put all of the `computer` values, the input states, that arrive into a big list of past inputs inside the time machine’s model.

### Put the history in a list

Add a new attribute to the time machine’s model named `history` which starts out as `[]`, an empty list.

<details>
  <summary>Click for hint</summary>
    
  Do this inside `initialStateWithTimeTravel`.
</details>
<details>
  <summary>Do I have to change the update function again, like when I added `paused`?</summary>
    
  No. When you added `paused`, you were switch over from only have the raw game’s model to having a new time machine model. Now, since you are already using the time machine model everywhere in `TimeTravel.elm`, you can add new attributes to it freely without breaking things.
</details>
<br>

Alter `updateWithTimeTravel` so that if the game is _not_ paused, in addition to updating `rawModel`, it _also_ appends the latest input state to `history`.
<details>
  <summary>Click for hint: What is the “latest input state?”</summary>
    
  It is `computer`. That one value contains all the inputs from the outside world that the game is allowed to use.
</details>
<details>
  <summary>Click for hint: How do I append one element to a list?</summary>
    
  Use `list ++ [newElement]`.
</details>
<details>
  <summary>Click for solution</summary>
    
  ```elm
  updateWithTimeTravel rawGame computer model =
    if ...
      ...
    else
      { model
        | rawModel = rawGame.updateState computer model.rawModel
        , history = model.history ++ [computer]
      }
  ```
</details>

### Visualize history

Add the following constant and helper function to your time travel module:

```elm
maxVisibleHistory = 2000

-- Converts an index in the history list to an x coordinate on the screen
historyIndexToX computer index =
  (toFloat index) / maxVisibleHistory * computer.screen.width
```

Add the following graphics helper function to the `let` block inside `viewWithTimeTravel`, immediately above `helpMessage`:

```elm
    -- Creates a rectangle at the top of the screen, stretching from the
    -- left edge up to a specific position within the history timeline
    historyBar color opacity index =
      let
        width = historyIndexToX computer index
      in
        rectangle color width controlBarHeight  
          |> move (computer.screen.left + width / 2)
                  (computer.screen.top - controlBarHeight / 2)
          |> fade opacity
```

Now, find the code where you add the white words to the screen. In the same list of things you are adding, just _before_ the words (so that the words still are in the foreground!), use `historyBar` to add two rectangles:

- A `black` rectangle with opacity `0.3` that stretches all the way to `maxVisibleHistory` (which is the right edge of the screen)
- A rectangle of any color you like (e.g. `(rgb 0 0 255)`) and opacity 0.6 that stretches up to the length of the `history` list.

<details>
  <summary>Click for hint: How do I get the length of the `history` list?</summary>
    
  The function for getting the length is `List.length`, and the `history` list is an attribute of the `model` record.

  Remember that you may need parentheses to nest function calls.
</details>
<br>

Run this, and you should see a nice transparent black background at the top of the screen, and a colorful bar slowly growing across it as time passes. You should still see the “Press T to time travel” message on top of the bars.

Make sure the bar stops growing when you press T, and resumes when you press R. You can reload the page if the bar goes off the end.

You probably want to close that browser window if you are going to do something else, since you now have a list growing without bound!

### Time to take stock

What have we done so far?

- Successfully wrapped an arbitrary game inside a “time machine” layer that can add to and control the game’s state and appearance.
- Added controls to start and stop the flow of events to the wrapped game.
- Created a list that holds all input the game received since starting.

The last step is to use that list of past input to recreate past states, then hook that up to a UI.

Next step: [Achieve time travel](2-time-machine-step-3.md)
