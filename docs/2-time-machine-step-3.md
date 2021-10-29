# Part 2: Build a time machine

## Step 3: Achieve time travel

### Add `historyPlaybackPosition`

To make the time machine work, we need to add one more thing to the time machine model: once we start moving into the past, the _currently displayed time_ will no longer be the same as the _latest time_.

Add a new `historyPlaybackPosition` to the time machine model with the following specification:

- `historyPlaybackPosition` starts at zero.
- When the game is unpaused and time is flowing normally, in addition to updating `rawModel` and `history`, the time machine also sets `historyPlaybackPosition` equal to the length of `model.history` plus 1. (Think: Why do we have to add 1 to the length of `model.history`?)
- The time machine’s view adds a third `historyBar` in a different color, after the other two bars but before the words, which extends to `historyPlaybackPosition`.

Test this. You should once again see the bar growing, and the new bar’s color should completely cover the old one. As before, the bar should stop growing when you pause, and start when you unpause.

### Implement time machine controls

Add the following helper function to the file:

```elm
-- Converts the mouse's current position to an index within the history list
mousePosToHistoryIndex computer =
  (computer.mouse.x - computer.screen.left)
    / computer.screen.width * maxVisibleHistory
  |> round
```

Now add a condition to the start (make sure it’s the start!) of the if / else chain in `updateWithTimeTravel` that does the following

- If time is paused **and** the mouse is down (`computer.mouse.down`), then:
  - Use `let … in …` to set `newPlaybackPosition` equal to the minimum (using the `min` function) of the following two values:

    - `mousePosToHistoryIndex computer`, and
    - the current length of `history`.

    Taking the minimum this way ensure that we can't drag into the future. (This isn’t that kind of time machine, alas! Even fancy programming languages can’t do that.)
  - In the `in` part of the `let … in …` clause, update the model’s `historyPlaybackPosition` to be `newPlaybackPosition`.

<details>
  <summary>Click for hint: A sketch of the code, with gaps for you to fill in</summary>
  

  Fill in the gaps marked with `❰❰` `❱❱`:
  ```elm
  if ❰❰ model is paused ❱❱ and ❰❰ mouse is down ❱❱ then
    let
      newPlaybackPosition =
        min (mousePosToHistoryIndex computer) (❰❰ length of history ❱❱)
    in
      { model
        | historyPlaybackPosition = newPlaybackPosition
      }
  else ...existing code...
  ```
</details>
<br>

Test the app. When the app is paused, you should be able to drag the bar at the top back and forth, and see the “history playback position” bar diverge from the “current history length” bar. No time travel yet, but our machine has controls!

Now it’s time hook those controls up to time.

### Fire up that flux capacitor and hop into the space-time vortex

Let’s make dragging that history bar recreate past states. How will this work?

You know the state that the raw game started in: it’s `rawGame.initialState`. Even after time has passed and the game has changed, `rawGame.initialState` is still there! So you can always get back the starting state of the game.

You know how the game state changed from one moment to the next: that’s always `rawGame.updateState`. Anything that ever happened in the game — anything, even just time passing! — could _only_ be a result of calling `rawGame.updateState` over and over, passing in the previous state plus any user input in the form of the `computer` parameter.

And you have all that user input: you’ve saved ever `computer` value that came along, in `model.history`. So you have all the information you need to recreate the entire state of the game at any point in the past!

The game state at any given moment `n` is basically:

```elm
rawGame.updateState model.history[n] somePreviousState
```

…which is:

```elm
rawGame.updateState model.history[n] (
  rawGame.updateState model.history[n - 1] someEarlierPreviousState
)
```

…which is:

```elm
rawGame.updateState model.history[n] (
  rawGame.updateState model.history[n-1] (
    rawGame.updateState model.history[n-2] someEvenEarlierState
  )
)
```

…which eventually boils down to:

```elm
rawGame.updateState model.history[n] (
  rawGame.updateState model.history[n-1] (
    rawGame.updateState model.history[n-2] (
      ...
        rawGame.updateState model.history[2] (
          rawGame.updateState model.history[1] (
            rawGame.updateState model.history[0] (
              rawGame.initialState
            )
          )
        )
      ...
    )
  )
)
```

So you need to write code that starts with `rawGame.initialState`, then applies `rawGame.updateState` over and over, passing each successive element of `model.history` as the first argument, and the previous result as the second argument.

Fortunately, Elm has a function that does exactly that: [`List.foldl`](https://package.elm-lang.org/packages/elm/core/latest/List#foldl) (“fold left”).

Ready to time travel?

In `updateWithTimeTravel`, inside that `let … in …` block you just created, immediately after `newPlaybackPosition`, create a new function `replayHistory pastInputs`. The `pastInputs` parameter will be a list of past `computer` values. The function starts from the raw game’s initial state, applies the update function with all those past inputs, and recreates the state of the game after receiving all those inputs.

The definition will look like this:

```elm
replayHistory pastInputs =
  List.foldl ❰❰ something involving rawGame.initialState, rawGame.updateState, and pastInputs ❱❱
```

The solution is not complicated! It may be hard to figure out, but it **is not complicated**. Study the documentation for `foldl` and think. If it passes the type checker, you’ve probably got it. If it gets longer than one line of code, step back and think, take a break, and/or ask for help.

---

Now, in `updateWithTimeTravel`, in that spot where you update `historyPlaybackPosition`, you need to _also_ update `rawModel`. By doing that, you will be passing the raw game one of its past states. You won’t be _updating_ that state while the time machine is paused, but the `rawGame.view` will still see it and display it! That’s how we see into the past.

But what do you update `rawModel` _to?_ Use [`List.take`](https://package.elm-lang.org/packages/elm/core/latest/List#take) to get the sublist of `model.history` up to `newPlaybackPosition`. Then pass that list of past inputs to `replayHistory`.

<details>
  <summary>Click for hint: Where the pieces described above fit in</summary>
  

  Fill in the gaps marked with `❰❰` `❱❱`:
  ```elm
    let
      newPlaybackPosition = ...you already have this...

      replayHistory pastInputs =
        ❰❰ process involving List.foldl described above ❱❱
    in
      { model
        | historyPlaybackPosition = newPlaybackPosition
        , rawModel = ❰❰ Use List.take to get history up to newPlaybackPosition, pass that to replayHistory ❱❱
      }
  ```
</details>
<br>

Test this. When you freeze time with T, you should be able to drag back and forth across the bar and control time!

### Please watch your step when exiting the time machine

There’s one much crucial piece: when you travel back in time and then unfreeze time, you need to remove the unused now-future history and restart the history recording at the point you just dragged back to.

Find the place in the code where you unpause the game. (Where is that?) In that spot, when you update `paused` to false, you now _also_ need to update `history` to include only the portion of history up to `historyPlaybackPosition`.

<details>
  <summary>Click for hint: How do I get only the portion of history up to `historyPlaybackPosition`?</summary>

  Use `List.take`.
</details>
<details>
  <summary>Click for hint: Sketch of the code, with gaps to fill in</summary>
  

  Fill in the gaps marked with `❰❰` `❱❱`:
  ```elm
  else if keyPressed "R" computer then
    { model
      | paused = False
      , history = ❰❰ history just up to historyPlaybackPosition ❱❱  -- restart at selected point...
    }
  ```
</details>
<br>

Test the app once more. Freeze, drag back in time, and then unfreeze **while watching the bar**. When you unfreeze, the bar should immediately jump back to the point you dragged to, instead of continuing to grow from its old size.

**Add some help text** in the view so that when the time machine is paused, in addition to telling the user they can press R to resume, it also tells them they can drag to travel in time.

Enjoy your time machine! I think it’s especially fun with the Asteroids game.

⚠️ Don’t forget to commit **and** push. ⚠️

### Small bonus challenge (Optional)

Add a feature so that the user can press C to reset the entire game and history and everything back to the initial state.

It is possible to do this in only two additional lines of code (including the if statement)! However, it’s tricky to see how to make the problem that simple. If you are enjoying Elm, see if you can figure it out.

### Big bonus challenge (VERY Optional)

If you get inspired and write your own little Elm game, I would be hard pressed not to give you a few points of extra credit.
