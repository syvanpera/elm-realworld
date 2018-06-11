module Page.Login exposing (Model, Msg, init, view, update)

import Html exposing (Html, div, h1, p, form, fieldset, input, button, text, a, ul, li)
import Html.Attributes exposing (class, placeholder, type_, href, value, hidden)
import Html.Events exposing (onInput, onSubmit)
import Http
import Api.User exposing (loginUser)
import Data.User exposing (User)
import Data.Session exposing (Session)
import Ports exposing (storeSession)
import Debug


type alias Model =
    { email : String
    , password : String
    , errors : List String
    }


type Msg
    = EmailInput String
    | PasswordInput String
    | Login
    | LoginResponse (Result Http.Error User)


initialModel : Model
initialModel =
    Model "" "" []


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
                        [ text "Sign in" ]
                    , p [ class "text-xs-center" ]
                        [ a [ href "#/register" ]
                            [ text "Need an account?" ]
                        ]
                    , List.map (\error -> li [] [ text error ]) model.errors
                        |> ul [ class "error-messages", hidden (List.isEmpty model.errors) ]
                    , form [ onSubmit Login ]
                        [ fieldset [ class "form-group" ]
                            [ input
                                [ class "form-control form-control-lg"
                                , placeholder "Email"
                                , type_ "text"
                                , value model.email
                                , onInput EmailInput
                                ]
                                []
                            ]
                        , fieldset [ class "form-group" ]
                            [ input
                                [ class "form-control form-control-lg"
                                , placeholder "Password"
                                , type_ "password"
                                , value model.password
                                , onInput PasswordInput
                                ]
                                []
                            ]
                        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
                            [ text "Sign in" ]
                        ]
                    ]
                ]
            ]
        ]


update : Maybe Session -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        EmailInput email ->
            ( { model | email = email }, Cmd.none )

        PasswordInput password ->
            ( { model | password = password }, Cmd.none )

        Login ->
            ( model, Http.send LoginResponse (loginUser model.email model.password) )

        LoginResponse (Err error) ->
            let
                _ =
                    Debug.log "Login error" error
            in
                ( { model | errors = [ "something went wrong" ] }, Cmd.none )

        LoginResponse (Ok user) ->
            let
                _ =
                    Debug.log "Login ok" user
            in
                ( model, storeSession (Session user.username user.token) )
