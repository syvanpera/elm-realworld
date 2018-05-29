module Main exposing (main)

import Html exposing (Html, div, text)
import Navigation exposing (Location)
import Model exposing (Session)
import Routing exposing (Route(..), parseLocation)
import Header
import Footer
import Page.Home as Home
import Page.Login as Login
import Page.Register as Register
import Debug


type alias Model =
    { appName : String
    , route : Route
    , session : Maybe Session
    , page : Page
    , homeModel : Home.Model
    , loginModel : Login.Model
    , registerModel : Register.Model
    }


type Msg
    = NoOp
    | SetRoute Location
    | HomeMsg Home.Msg
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg


type Page
    = Home
    | Login
    | Register



-- | Register


initialModel : Route -> Model
initialModel route =
    { appName = "Conduit"
    , route = route
    , session = Nothing
    , page = Home
    , homeModel = Home.initialModel
    , loginModel = Login.initialModel
    , registerModel = Register.initialModel
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parseLocation location
    in
        ( initialModel currentRoute, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ Header.view model.appName model.session
        , viewPage model
        , Footer.view model.appName
        ]


viewPage : Model -> Html Msg
viewPage model =
    case model.page of
        Home ->
            Html.map HomeMsg (Home.view model.homeModel)

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
                -- let
                --     pageCmd =
                --         Home.init
                -- in
                --     ( { model | route = route, page = Home }, Cmd.map HomeMsg pageCmd )
                ( { model | route = route, page = Home }, Cmd.none )

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
