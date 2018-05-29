module Page.Login exposing (Model, Msg, initialModel, view, update)

import Html exposing (Html, div, h1, p, form, fieldset, input, button, text, a, ul, li)
import Html.Attributes exposing (class, placeholder, type_, href, value)
import Html.Events exposing (onInput)


type alias Model =
    { email : String
    , password : String
    }


type Msg
    = NoOp
    | EmailInput String
    | PasswordInput String


initialModel : Model
initialModel =
    Model "" ""


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
                    , ul [ class "error-messages" ]
                        [ li []
                            [ text "email or password is invalid" ]
                        ]
                    , form []
                        [ fieldset [ class "form-group" ]
                            [ input [ class "form-control form-control-lg", placeholder "Email", type_ "text", value model.email, onInput EmailInput ]
                                []
                            ]
                        , fieldset [ class "form-group" ]
                            [ input [ class "form-control form-control-lg", placeholder "Password", type_ "password", value model.password, onInput PasswordInput ]
                                []
                            ]
                        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
                            [ text "Sign in" ]
                        ]
                    ]
                ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EmailInput email ->
            ( { model | email = email }, Cmd.none )

        PasswordInput password ->
            ( { model | password = password }, Cmd.none )
