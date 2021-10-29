# Part 1: Make a small change

Change something in either Mario or Asteroids. It needs to be something bigger than just changing a color or a physics constant, but it doesn't need to be _much_ bigger than that.

The best thing to do is just tinker and see what you come up with. But if your mind is blank, or you want a good challenge, here are some suggestions:

- Make it so that Mario or the asteroids bounce off the side of the screen instead of wrapping around.
- Add a jump counter that shows how many times Mario has jumped, or a shot counter that shows how many times the ship has fired. (You can use a `words` element in the view to display it.)
- Make it so that there is an orange rectangle of lava near Mario, and Mario has to jump over it or he “dies” by getting sent back to the middle.
- Make it so that the asteroids all pull on each other with gravity.
- Make all the asteroids different colors. (This one is surprisingly difficult, because of how the existing code is structured!)

These are just suggestions to get you thinking. I encourage you to experiment and come up with your own idea. Don’t overcomplicate it, however. The goal here is to get a feel for Elm, not to make the Next Great Video Game Hit.

You will find the [documentation for the Elm Playground module](https://package.elm-lang.org/packages/evancz/elm-playground/latest/Playground) useful. Note that these games use the `game` application builder function in `Playground` (as opposed to `picture` or `animation`).

Once you have made your change and tested it, **commit your work**. Please make sure that this change ends up in a commit of its own, separate from part 2!

Did you commit your work? Get up and stretch? Proceed to [Part 2](2-time-machine-step-0.md).
