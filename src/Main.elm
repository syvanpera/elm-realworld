module Main exposing (main)

import Html exposing (Html, div)
import Navigation exposing (Location)
import Model exposing (Session)
import Routing exposing (Route(..), parseLocation)
import Ports
import Page.Home as Home
import Page.Article as Article
import Page.Profile as Profile
import Page.Login as Login
import Page.Register as Register
import Views.Footer as Footer
import Views.Header as Header


type alias Model =
    { route : Route
    , session : Maybe Session
    , page : Page
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
    = Blank
    | Home Home.Model
    | Article Article.Model
    | Profile Profile.Model
    | Login Login.Model
    | Register Register.Model


initialModel : Model
initialModel =
    { route = Routing.Home
    , session = Nothing
    , page = Blank
    }


init : Maybe Session -> Location -> ( Model, Cmd Msg )
init session location =
    setRoute location { initialModel | session = session }


view : Model -> Html Msg
view model =
    div []
        [ Header.view model.session
        , viewPage model.session model.page
        , Footer.view
        ]


viewPage : Maybe Session -> Page -> Html Msg
viewPage session page =
    case page of
        Blank ->
            Html.text ""

        Home subModel ->
            Html.map HomeMsg (Home.view session subModel)

        Article subModel ->
            Html.map ArticleMsg (Article.view session subModel)

        Profile subModel ->
            Html.map ProfileMsg (Profile.view subModel)

        Login subModel ->
            Html.map LoginMsg (Login.view subModel)

        Register subModel ->
            Html.map RegisterMsg (Register.view subModel)


setRoute : Location -> Model -> ( Model, Cmd Msg )
setRoute location model =
    let
        route =
            parseLocation location

        initPage page route toMsg subInit =
            let
                ( pageModel, pageCmd ) =
                    subInit model.session
            in
                ( { model | route = route, page = page pageModel }, Cmd.map toMsg pageCmd )
    in
        case route of
            Routing.Home ->
                initPage Home route HomeMsg Home.init

            Routing.Article slug ->
                initPage Article route ArticleMsg (Article.init slug)

            Routing.Profile username ->
                initPage Profile route ProfileMsg (Profile.init username)

            Routing.Login ->
                initPage Login route LoginMsg Login.init

            Routing.Register ->
                initPage Register route RegisterMsg Register.init

            Routing.NotFound ->
                initPage Home route HomeMsg Home.init


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        toPage page toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate model.session subMsg subModel
            in
                ( { model | page = page newModel }, Cmd.map toMsg newCmd )
    in
        case ( msg, model.page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( HomeMsg subMsg, Home subModel ) ->
                toPage Home HomeMsg Home.update subMsg subModel

            ( ArticleMsg subMsg, Article subModel ) ->
                toPage Article ArticleMsg Article.update subMsg subModel

            ( ProfileMsg subMsg, Profile subModel ) ->
                toPage Profile ProfileMsg Profile.update subMsg subModel

            ( LoginMsg subMsg, Login subModel ) ->
                toPage Login LoginMsg Login.update subMsg subModel

            ( RegisterMsg subMsg, Register subModel ) ->
                toPage Register RegisterMsg Register.update subMsg subModel

            ( SessionChanged session, _ ) ->
                let
                    _ =
                        Debug.log "session changed" session
                in
                    ( { model | session = Just session }, Cmd.none )

            ( _, _ ) ->
                ( model, Cmd.none )


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
