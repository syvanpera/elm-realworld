module Main exposing (main)

import Html exposing (Html, div, text)
import Navigation exposing (Location)
import Model exposing (Session)
import Routing exposing (Route(..), parseLocation)
import Header
import Footer
import Page.Home as Home
import Page.Article as Article
import Page.Login as Login
import Page.Register as Register


type alias Model =
    { route : Route
    , session : Maybe Session
    , page : Page
    , homeModel : Home.Model
    , articleModel : Article.Model
    , loginModel : Login.Model
    , registerModel : Register.Model
    }


type Msg
    = NoOp
    | SetRoute Location
    | HomeMsg Home.Msg
    | ArticleMsg Article.Msg
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg


type Page
    = Home
    | Article
    | Login
    | Register


initialModel : Model
initialModel =
    { route = Routing.Home
    , session = Nothing
    , page = Home
    , homeModel = Home.initialModel
    , articleModel = Article.initialModel
    , loginModel = Login.initialModel
    , registerModel = Register.initialModel
    }


init : Location -> ( Model, Cmd Msg )
init location =
    setRoute location initialModel


view : Model -> Html Msg
view model =
    div []
        [ Header.view model.session
        , viewPage model
        , Footer.view
        ]


viewPage : Model -> Html Msg
viewPage model =
    case model.page of
        Home ->
            Html.map HomeMsg (Home.view model.homeModel)

        Article ->
            Html.map ArticleMsg (Article.view model.articleModel)

        Login ->
            Html.map LoginMsg (Login.view model.loginModel)

        Register ->
            Html.map RegisterMsg (Register.view model.registerModel)


setRoute : Location -> Model -> ( Model, Cmd Msg )
setRoute location model =
    let
        route =
            parseLocation location
    in
        case route of
            Routing.Home ->
                let
                    ( pageModel, pageCmd ) =
                        Home.init
                in
                    ( { model | route = route, page = Home, homeModel = pageModel }, Cmd.map HomeMsg pageCmd )

            Routing.Article slug ->
                let
                    ( pageModel, pageCmd ) =
                        Article.init slug
                in
                    ( { model | route = route, page = Article, articleModel = pageModel }, Cmd.map ArticleMsg pageCmd )

            Routing.Login ->
                ( { model | route = route, page = Login }, Cmd.none )

            Routing.Register ->
                ( { model | route = route, page = Register }, Cmd.none )

            Routing.NotFound ->
                ( { model | route = route, page = Home }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetRoute location ->
            setRoute location model

        HomeMsg subMsg ->
            let
                ( pageModel, pageCmd ) =
                    Home.update subMsg model.homeModel
            in
                ( { model | homeModel = pageModel }, Cmd.map HomeMsg pageCmd )

        ArticleMsg subMsg ->
            let
                ( pageModel, pageCmd ) =
                    Article.update subMsg model.articleModel
            in
                ( { model | articleModel = pageModel }, Cmd.map ArticleMsg pageCmd )

        LoginMsg subMsg ->
            let
                ( pageModel, pageCmd ) =
                    Login.update subMsg model.loginModel
            in
                ( { model | loginModel = pageModel }, Cmd.map LoginMsg pageCmd )

        RegisterMsg subMsg ->
            let
                ( pageModel, pageCmd ) =
                    Register.update subMsg model.registerModel
            in
                ( { model | registerModel = pageModel }, Cmd.map RegisterMsg pageCmd )


main : Program Never Model Msg
main =
    Navigation.program SetRoute
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
