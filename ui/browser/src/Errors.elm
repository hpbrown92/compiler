module Errors exposing (main)


import Browser
import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import String
import Json.Decode as D
import Elm.Error as Error



-- MAIN


main =
  Browser.fullscreen
    { init = \env -> (D.decodeValue Error.decoder env.flags, Cmd.none)
    , update = \_ exit -> (exit, Cmd.none)
    , view = view
    , subscriptions = \_ -> Sub.none
    , onNavigation = Nothing
    }



-- VIEW


view : Result D.Error Error.Error -> Browser.View msg
view result =
  { title = "Problem!"
  , body =
      case result of
        Err err ->
          [ text (D.errorToString err) ]

        Ok error ->
          [ viewError error ]
  }


viewError : Error.Error -> Html msg
viewError error =
  div
    [ style "width" "100%"
    , style "min-height" "100%"
    , style "display" "flex"
    , style "flex-direction" "column"
    , style "align-items" "center"
    , style "background-color" "black"
    , style "color" "rgb(233, 235, 235)"
    , style "font-family" "monospace"
    ]
    [ div
        [ style "display" "block"
        , style "white-space" "pre-wrap"
        , style "background-color" "rgb(39, 40, 34)"
        , style "padding" "2em"
        ]
        (viewErrorHelp error)
    ]


viewErrorHelp : Error.Error -> List (Html msg)
viewErrorHelp error =
  case error of
    Error.GeneralProblem { path, title, message } ->
      [ text title ]

    Error.ModuleProblems badModules ->
      List.map viewBadModule badModules


viewBadModule : Error.BadModule -> Html msg
viewBadModule { path, name, problems } =
  span [] (List.map (viewProblem path) problems)


viewProblem : String -> Error.Problem -> Html msg
viewProblem filePath problem =
  let
    leftover =
      76 - String.length problem.title

    header =
      "-- " ++ problem.title ++ " " ++ String.padLeft leftover '-' (" " ++ filePath) ++ "\n\n"
  in
  span []
    ( span [ style "color" "cyan" ] [ text header ]
      :: viewMessage problem.message
    )



-- VIEW MESSAGE


viewMessage : List Error.Chunk -> List (Html msg)
viewMessage chunks =
  case chunks of
    [] ->
      []

    chunk :: others ->
      let
        htmlChunk =
          case chunk of
            Error.Unstyled string ->
              text string

            Error.Styled style string ->
              span (styleToAttrs style) [ text string ]
      in
      htmlChunk :: viewMessage others


styleToAttrs : Error.Style -> List (Attribute msg)
styleToAttrs { bold, underline, color } =
  addBold bold <| addUnderline underline <| addColor color []


addBold : Bool -> List (Attribute msg) -> List (Attribute msg)
addBold bool attrs =
  if bool then
    style "font-weight" "bold" :: attrs
  else
    attrs


addUnderline : Bool -> List (Attribute msg) -> List (Attribute msg)
addUnderline bool attrs =
  if bool then
    style "text-decoration" "underline" :: attrs
  else
    attrs


addColor : Maybe Error.Color -> List (Attribute msg) -> List (Attribute msg)
addColor maybeColor attrs =
  case maybeColor of
    Nothing ->
      attrs

    Just color ->
      style "color" (colorToCss color) :: attrs


colorToCss : Error.Color -> String
colorToCss color =
  case color of
    Error.Red -> "red"
    Error.RED -> "red"
    Error.Magenta -> "magenta"
    Error.MAGENTA -> "magenta"
    Error.Yellow -> "yellow"
    Error.YELLOW -> "yellow"
    Error.Green -> "green"
    Error.GREEN -> "green"
    Error.Cyan -> "cyan"
    Error.CYAN -> "cyan"
    Error.Blue -> "blue"
    Error.BLUE -> "blue"
    Error.White -> "white"
    Error.WHITE -> "white"
    Error.Black -> "black"
    Error.BLACK -> "black"
