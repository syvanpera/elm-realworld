module Views.Header exposing (view)

import Html exposing (Html, nav, div, a, ul, li, i, text)
import Html.Attributes exposing (class, href)
import Data.Session exposing (Session)
import Debug


navigation : Maybe Session -> List (Html msg)
navigation maybeSession =
    case maybeSession of
        Just session ->
            [ li [ class "nav-item" ]
                [ a [ class "nav-link", href "" ] [ i [ class "ion-compose" ] [], text " New Article" ] ]
            , li [ class "nav-item" ]
                [ a [ class "nav-link", href "" ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ]
            , li [ class "nav-item" ]
                [ a [ class "nav-link", href ("#/profile/" ++ session.username) ] [ text session.username ] ]
            ]

        Nothing ->
            [ li [ class "nav-item" ]
                [ a [ class "nav-link", href "#/login" ] [ text "Sign in" ] ]
            , li [ class "nav-item" ]
                [ a [ class "nav-link", href "#/register" ] [ text "Sign up" ] ]
            ]


view : Maybe Session -> Html msg
view session =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ href "#/", class "navbar-brand" ]
                [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                (li [ class "nav-item" ]
                    [ a [ class "nav-link", href "#/" ] [ text "Home" ] ]
                    :: navigation session
                )
            ]
        ]
