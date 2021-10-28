module TimeTravel exposing (addTimeTravel)

import Playground exposing (..)
import Set
import Time as PosixTime
import Browser

type alias TimeTravelModel rawModel =
  { history : List Computer
  , historyPlaybackPosition : Int
  , paused : Bool
  , rawModel : rawModel
  }

addTimeTravel rawGame =
  { initialState = initialStateWithTimeTravel rawGame
  , updateState = updateWithTimeTravel rawGame
  , view = viewWithTimeTravel rawGame
  }

maxVisibleHistory = 2000
historySize model = List.length model.history
historyBarHeight = 64

-- Use the game's own (raw) initial state, plus an empty history

initialStateWithTimeTravel rawGame =
  { rawModel = rawGame.initialState
  , history = []
  , historyPlaybackPosition = 0
  , paused = False
  }

-- viewWithTimeTravel adds a time travel bar + help message to the game’s normal UI

viewWithTimeTravel rawGame computer model =
  let
    historyIndexToX index = (toFloat index) / maxVisibleHistory * computer.screen.width
    historyBar color opacity index =
      let
        width = historyIndexToX index
      in
        rectangle color width historyBarHeight  
          |> move (computer.screen.left + width / 2) (computer.screen.top - historyBarHeight / 2)
          |> fade opacity
    helpMessage =
        if model.paused then
          "Drag bar to time travel  •  Press R to resume  •  Press C to clear history & restart"
        else
          "Press T to time travel"
  in
    (rawGame.view computer model.rawModel) ++
      [ historyBar black 0.3 maxVisibleHistory
      , historyBar (rgb 0 0 255) 0.6 (List.length model.history)
      , historyBar (rgb 128 64 255) 0.9 model.historyPlaybackPosition
      , words white helpMessage
          |> move 0 (computer.screen.top - historyBarHeight / 2)
      ]

updateWithTimeTravel rawGame computer model =
  -- Pause game & travel in time

  if model.paused && computer.mouse.down && computer.mouse.y > computer.screen.top - historyBarHeight then
    let
      xToHistoryIndex x =
        (x - computer.screen.left)
          / computer.screen.width * maxVisibleHistory
        |> round

      newPlaybackPosition =
        min (List.length model.history) (xToHistoryIndex computer.mouse.x)

      replayHistory computerEvents =
        List.foldl rawGame.updateState rawGame.initialState computerEvents
    in
      { model
        | rawModel = replayHistory (List.take newPlaybackPosition model.history)
        , historyPlaybackPosition = newPlaybackPosition
      }

  -- Toggling pause mode

  else if keyPressed "T" computer then
    { model
      | paused = True
    }

  else if keyPressed "R" computer then
    { model
      | paused = False
      , history = List.take model.historyPlaybackPosition model.history  -- start at selected point...
    }

  -- Clear history & restart

  else if model.paused && keyPressed "C" computer then
    initialStateWithTimeTravel rawGame

  -- Paused and doing nothing

  else if model.paused then
    model

  -- Normal gameplay

  else
    { model
      | rawModel = rawGame.updateState computer model.rawModel
      , history = model.history ++ [computer]
      , historyPlaybackPosition = (List.length model.history + 1)
    }

-- Helpers --

keyPressed keyName computer =
  [ String.toLower keyName
  , String.toUpper keyName
  ]
    |> List.any (\key -> Set.member key computer.keyboard.keys)
