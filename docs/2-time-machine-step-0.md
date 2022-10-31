# Part 2: Build a time machine

These instructions walk you through building the entire time machine from scratch. However, much of the code is provided in hints. You can and should challenge yourself to puzzle over each piece before you look at each hint. However, you _should_ look at the hints!

To give you a sense of scale, when you are all done, the time machine file will be **about 90 lines of code**, give or take, depending on how you format things.

## Step 0: Make a pass-through model

Edit `src/TimeTravel.elm`. Add a function named `addTimeTravel` that takes a parameter named `rawGame`, and simply returns it.

<details>
  <summary>Click for solution</summary>
  
  ```elm
  addTimeTravel rawGame =
    rawGame
  ```
</details>
<br>

Here, `rawGame` is some game without time travel (Asteroids, Mario, whatever). We take that whole game as our input. We will eventually make `addTimeTravel` do exciting things with it, but right now, we should be able to pass a whole application through `addTimeTravel` and have it do nothing. Let’s test it!

Edit `src/Main.elm`, and add an import at the top for your new time travel module:

```elm
import TimeTravel exposing (addTimeTravel)
```

Add the `addTimeTravel` function to the pipeline, before `gameApplication`.

<details>
  <summary>Click for solution</summary>
  
  ```elm
  main = Mario.game  -- or Asteroids.game, either should work
    |> addTimeTravel
    |> gameApplication
  ```
</details>
<br>

Run the app. It should work exactly as before. (Why? Because `addTimeTravel` is the identity function, so adding it to the pipeline does nothing. So why are we testing this? Because it makes sure that your new module is set up properly.)

### Destructuring

Now we are going to make `addTimeTravel` deconstruct that game value just a little bit, then put it back together. Our `addTimeTravel` will still do nothing, but it will do nothing with more awareness of `rawGame`’s structure.

Modify `addTimeTravel` so that it returns a record with the attributes `initialState`, `updateState`, and `view`, where each of those attributes comes from the corresponding attribute of `rawGame`. In other words, we are copying `rawGame`’s parts into our own new, potentially different game.

<details>
  <summary>Click for solution</summary>
  
  ```elm
  addTimeTravel rawGame =
    { initialState = rawGame.initialState
    , updateState = rawGame.updateState
    , view = rawGame.view
    }
  ```
</details>
<br>

Test that code, and make sure things still work as before.

### Splitting the work into new functions

We have one more iteration of making `addTimeTravel` do nothing! This time, though, we are going to use three separate functions to do it. These three functions will be the building blocks of our time machine. Add them to your `TimeTravel` module:

```elm
initialStateWithTimeTravel rawGame

viewWithTimeTravel rawGame computer model

updateWithTimeTravel rawGame computer model
```

Now implement each of them so that it does whatever it needs to do to delegate its work entirely to `rawGame`.

Make the `addTimeTravel` function call your three new helpers. This is a little tricky, but the solution is very simple! It is tricky because the `updateState` and `view` functions both expect a `computer` and a `model` parameter. But where do they come from? The `addTimeTravel` does not have access to any `computer` or `model`! So where is it supposed to get them?! How to implement it??

<details>
  <summary>Click for hint</summary>

  Use currying! For example, in the record that `addTimeTravel` returns, `initialState` is supposed to be a function with _two_ parameters. You have an `initialStateWithTimeTravel` function that takes _three_ parameters. And right there in `addTimeTravel`, you have the value for the first parameter. So provide that first parameter, and leave the two remaining ones unapplied.

</details>
<details>
  <summary>Click for solution</summary>
    
  ```elm
  addTimeTravel rawGame =
    { initialState = initialStateWithTimeTravel rawGame
    , updateState = updateWithTimeTravel rawGame
    , view = viewWithTimeTravel rawGame
    }

  initialStateWithTimeTravel rawGame =
    rawGame.initialState

  viewWithTimeTravel rawGame computer model =
    rawGame.view computer model

  updateWithTimeTravel rawGame computer model =
    rawGame.updateState computer model
  ```
</details>
<br>

Test that, and make sure that the game still works like it’s supposed to.

Next step: [Freeze time](2-time-machine-step-1.md)
