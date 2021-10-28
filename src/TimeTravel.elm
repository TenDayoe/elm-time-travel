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
  let
    maxVisibleHistory = 2000
    historySize model = List.length model.history
    historyBarHeight = 64

    replayHistory events =
      List.foldl rawGame.updateState rawGame.initialState events

    -- Use the game's own (raw) initial state, plus an empty history

    initialStateWithTimeTravel =
      { rawModel = rawGame.initialState
      , history = []
      , historyPlaybackPosition = 0
      , paused = False
      }

    -- viewWithTimeTravel adds a time travel bar + help message to the game’s normal UI

    viewWithTimeTravel computer model =
      let
        historyIndexToX index = (index |> toFloat) / maxVisibleHistory * computer.screen.width
        historyBar color index =
          let
            width = historyIndexToX index
          in
            rectangle color width historyBarHeight  
              |> move (computer.screen.left + width / 2) (computer.screen.top - historyBarHeight / 2)
              |> fade 0.9
        helpMessage =
            if model.paused then
              "Drag bar to time travel  •  Press R to resume  •  Press C to clear history & restart"
            else
              "Press T to time travel"
      in
        (rawGame.view computer model.rawModel) ++
          [ historyBar black maxVisibleHistory
          , historyBar (rgb 0 0 255) (List.length model.history)
          , historyBar (rgb 128 64 255) model.historyPlaybackPosition
          , words white helpMessage
              |> move 0 (computer.screen.top - historyBarHeight / 2)
          ]

    -- replayHistory sets up the initial state of the game using previously recorded history, if any

    updateWithTimeTravel computer model =
      let
        xToHistoryIndex x =
          (x - computer.screen.left)
            / computer.screen.width * maxVisibleHistory
          |> round
      in
        -- Pause game & travel in time

        if model.paused && computer.mouse.down && computer.mouse.y > computer.screen.top - historyBarHeight then
          let
            newPlaybackPosition =
              min (List.length model.history) (xToHistoryIndex computer.mouse.x)
          in
            { model
              | rawModel = replayHistory (List.take newPlaybackPosition model.history)
              , historyPlaybackPosition = newPlaybackPosition
            }

        -- Toggling pause mode

        else if List.any (\key -> Set.member key computer.keyboard.keys) ["t", "T"] then
          { model | paused = True}

        else if List.any (\key -> Set.member key computer.keyboard.keys) ["r", "R"] then
          { model
            | paused = False
            , history = List.take model.historyPlaybackPosition model.history  -- start at selected point...
          }

        -- Clear history & restart

        else if model.paused && List.any (\key -> Set.member key computer.keyboard.keys) ["c", "C"] then
          initialStateWithTimeTravel

        -- Paused and doing nothing

        else if model.paused then
          model

        -- Normal gameplay

        else
          { model
            | rawModel = rawGame.updateState computer model.rawModel
            , history = model.history ++ [computer]
            , historyPlaybackPosition = (List.length model.history + 1)
            , paused = False
          }
  in
    { initialState = initialStateWithTimeTravel
    , updateState = updateWithTimeTravel
    , view = viewWithTimeTravel
    }
