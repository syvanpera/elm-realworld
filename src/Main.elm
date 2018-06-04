module Main exposing (main)

import Html exposing (Html, div)
import Navigation exposing (Location)
import Model exposing (Session)
import Routing exposing (Route(..), parseLocation)
import Ports
import Header
import Footer
import Page.Home as Home
import Page.Article as Article
import Page.Profile as Profile
import Page.Login as Login
import Page.Register as Register


type alias Model =
    { route : Route
    , session : Maybe Session
    , page : Page
    , homeModel : Home.Model
    , articleModel : Article.Model
    , profileModel : Profile.Model
    , loginModel : Login.Model
    , registerModel : Register.Model
    }


type Msg
    = SetRoute Location
    | HomeMsg Home.Msg
    | ArticleMsg Article.Msg
    | ProfileMsg Profile.Msg
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg
    | SessionChanged Session


type Page
    = Home
    | Article
    | Profile
    | Login
    | Register


initialModel : Model
initialModel =
    { route = Routing.Home
    , session = Nothing
    , page = Home
    , homeModel = Home.initialModel
    , articleModel = Article.initialModel
    , profileModel = Profile.initialModel
    , loginModel = Login.initialModel
    , registerModel = Register.initialModel
    }


init : Maybe Session -> Location -> ( Model, Cmd Msg )
init session location =
    setRoute location { initialModel | session = session }


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
            Html.map HomeMsg (Home.view model.session model.homeModel)

        Article ->
            Html.map ArticleMsg (Article.view model.articleModel model.session)

        Profile ->
            Html.map ProfileMsg (Profile.view model.profileModel)

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

            Routing.Profile username ->
                let
                    ( pageModel, pageCmd ) =
                        Profile.init username
                in
                    ( { model | route = route, page = Profile, profileModel = pageModel }, Cmd.map ProfileMsg pageCmd )

            Routing.Login ->
                ( { model | route = route, page = Login }, Cmd.none )

            Routing.Register ->
                ( { model | route = route, page = Register }, Cmd.none )

            Routing.NotFound ->
                ( { model | route = route, page = Home }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute location ->
            setRoute location model

        HomeMsg subMsg ->
            let
                ( pageModel, pageCmd ) =
                    Home.update subMsg model.homeModel model.session
            in
                ( { model | homeModel = pageModel }, Cmd.map HomeMsg pageCmd )

        ArticleMsg subMsg ->
            let
                ( pageModel, pageCmd ) =
                    Article.update subMsg model.articleModel
            in
                ( { model | articleModel = pageModel }, Cmd.map ArticleMsg pageCmd )

        ProfileMsg subMsg ->
            let
                ( pageModel, pageCmd ) =
                    Profile.update subMsg model.profileModel
            in
                ( { model | profileModel = pageModel }, Cmd.map ProfileMsg pageCmd )

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

        SessionChanged session ->
            let
                _ =
                    Debug.log "session changed" session
            in
                ( { model | session = Just session }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.onSessionChange SessionChanged


main : Program (Maybe Session) Model Msg
main =
    Navigation.programWithFlags SetRoute
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
