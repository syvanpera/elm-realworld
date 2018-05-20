module Main exposing (..)

import Html exposing (Html, div, p, text, a)
import Html.Attributes exposing (class, href)
import Header
import Footer
import Banner
import Home
import Models exposing (initialModel, Model)
import Msgs exposing (Msg)
import Commands exposing (fetchArticles, fetchTags)


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.batch
        [ fetchArticles
        , fetchTags
        ]
    )


view : Model -> Html Msg
view model =
    div []
        [ Header.render model.appName model.isLoggedIn
        , div [ class "home-page" ]
            [ Banner.render model.appName
            , Home.render model.tags model.articles
            ]
        , Footer.render model.appName
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchArticles response ->
            ( { model | articles = response }, Cmd.none )

        Msgs.OnFetchTags response ->
            ( { model | tags = response }, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
