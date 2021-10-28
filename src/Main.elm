module Main exposing (..)

import Asteroids
import Mario
import TimeTravel exposing (addTimeTravel)
import Playground

gameApplication game =
    Playground.game game.view game.updateState game.initialState

main = gameApplication (addTimeTravel Mario.game)
