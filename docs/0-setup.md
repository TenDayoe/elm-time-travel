# Part 0: Install tools and get oriented

## Install the tools

Our class examples have run in Elm’s in-browser playground. For this project, however, you will need to install Elm on your own machine:

1. [Install Elm](https://guide.elm-lang.org/install/elm.html) on your machine.
2. [Install Node.js / npm](https://nodejs.org/en/download/).
    - You can check if you have it installed using the command line:
        ```
        npm --version
        ```
      (Make sure you have version 7 or newer.)
    - Note that if you are using macOS and already have Homebrew, it may be easier to install with:
        ```
        brew install node
        ```
3. Install elm-live, which will run your app with automatic recompilation and reloading when you save changes:
    ```
    npm install --global elm elm-live
    ```

To launch this project, open a command line **in this project directory**, then run:

    elm-live --open -- src/Main.elm --output=elm.js

Your browser should open with a little Mario who will run and jump when you press the arrow keys, and leave a trail behind. If this doesn't work, **reach out for help in the class channel** before proceeding.

**Leave the app open in your browser, and leave elm-live running in your console while you work!** If you do, the app will automatically update whenever you save changes.

## Study the structure

Look inside `src`, where you will find:

- `Mario.elm`: The game you were just playing
- `Asteroids.elm`: Another more complex game
- `Main.elm`: The main entry point for the application, which chooses which game to run
- `TimeTravel.elm`: An empty module that you will complete later in the assignment.

Open up `Main.elm`, and look for the definition of `main`. Change `Mario.game` to `Asteroid.game`. If you left elm-live running and left the app open in your browser, you should see the app switch to the new game as soon as you save changes.

Study the source code for `Mario.elm` and `Asteroids.elm`. Each of them defines a value named `game`, which is a record containing three functions. Think:

- What are those functions?
- What is the job of each of them?
- What are the inputs and outputs of each one?
- Would it be possible to mix and match the different functions from different games? Could you, for example, use the Mario `view` function with the `initialState` and `updateState` functions from Asteroids? Why or why not?

Ready to jump in? Proceed to [Part 1](1-small-change.md).
