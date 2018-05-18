module Main exposing (..)

import Html exposing (..)


type alias Model =
    String


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( "Hello", Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
