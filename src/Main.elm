module Main exposing (..)

import Html exposing (Html, div, p, text, a)
import Html.Attributes exposing (class, href)
import Navigation exposing (Location)
import Routing exposing (parseLocation)
import Header
import Footer
import Banner
import Home
import Article
import Models exposing (initialModel, Model)
import Msgs exposing (Msg)
import Commands exposing (fetchArticles, fetchTags)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parseLocation location
    in
        ( initialModel currentRoute
        , Cmd.batch
            [ fetchArticles
            , fetchTags
            ]
        )


view : Model -> Html Msg
view model =
    div []
        [ Header.view model.appName model.isLoggedIn
        , div [ class "home-page" ]
            [ Banner.view model.appName
            , page model
            ]
        , Footer.view model.appName
        ]


page : Model -> Html Msg
page model =
    case model.route of
        Models.HomeRoute ->
            Home.view model.tags model.articles

        Models.ArticleRoute slug ->
            Article.view

        Models.NotFoundRoute ->
            Home.view model.tags model.articles


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchArticles response ->
            ( { model | articles = response }, Cmd.none )

        Msgs.OnFetchArticle response ->
            ( { model | article = response }, Cmd.none )

        Msgs.OnFetchTags response ->
            ( { model | tags = response }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )


main : Program Never Model Msg
main =
    Navigation.program Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
