module Page.Register exposing (Model, Msg, init, view, update)

import Html exposing (Html, div, h1, p, form, fieldset, input, button, text, a, ul, li)
import Html.Attributes exposing (class, placeholder, type_, href, value, hidden)
import Html.Events exposing (onInput, onSubmit)
import Http
import Model exposing (User, Session)
import Api exposing (registerUser)
import Ports exposing (storeSession)
import Debug


type alias Model =
    { username : String
    , email : String
    , password : String
    , errors : List String
    }


type Msg
    = UsernameInput String
    | EmailInput String
    | PasswordInput String
    | Register
    | RegisterResponse (Result Http.Error User)


initialModel : Model
initialModel =
    Model "" "" "" []


init : Maybe Session -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ]
                        [ text "Sign up" ]
                    , p [ class "text-xs-center" ]
                        [ a [ href "#/login" ]
                            [ text "Have an account?" ]
                        ]
                    , List.map (\error -> li [] [ text error ]) model.errors
                        |> ul [ class "error-messages", hidden (List.isEmpty model.errors) ]
                    , form [ onSubmit Register ]
                        [ fieldset [ class "form-group" ]
                            [ input [ class "form-control form-control-lg", placeholder "Username", type_ "text", value model.username, onInput UsernameInput ]
                                []
                            ]
                        , fieldset [ class "form-group" ]
                            [ input [ class "form-control form-control-lg", placeholder "Email", type_ "text", value model.email, onInput EmailInput ]
                                []
                            ]
                        , fieldset [ class "form-group" ]
                            [ input [ class "form-control form-control-lg", placeholder "Password", type_ "password", value model.password, onInput PasswordInput ]
                                []
                            ]
                        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
                            [ text "Sign up" ]
                        ]
                    ]
                ]
            ]
        ]


update : Maybe Session -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        UsernameInput username ->
            ( { model | username = username }, Cmd.none )

        EmailInput email ->
            ( { model | email = email }, Cmd.none )

        PasswordInput password ->
            ( { model | password = password }, Cmd.none )

        Register ->
            ( model, Http.send RegisterResponse (registerUser model.username model.email model.password) )

        RegisterResponse (Err error) ->
            let
                _ =
                    Debug.log "Register error" error
            in
                ( { model | errors = [ "something went wrong" ] }, Cmd.none )

        RegisterResponse (Ok user) ->
            let
                _ =
                    Debug.log "Register ok" user
            in
                ( model, storeSession (Session user.username user.token) )
