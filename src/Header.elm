module Header exposing (view)

import Html exposing (Html, nav, div, a, ul, li, i, text)
import Html.Attributes exposing (class, href)
import Model exposing (Session)


navigation : Maybe Session -> List (Html msg)
navigation session =
    case session of
        Just session ->
            [ li [ class "nav-item" ]
                [ a [ class "nav-link", href "" ] [ i [ class "ion-compose" ] [], text " New Post" ] ]
            , li [ class "nav-item" ]
                [ a [ class "nav-link", href "" ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ]
            , li [ class "nav-item" ]
                [ a [ class "nav-link", href "" ] [ text session.username ] ]
            ]

        Nothing ->
            [ li [ class "nav-item" ]
                [ a [ class "nav-link", href "#/login" ] [ text "Sign in" ] ]
            , li [ class "nav-item" ]
                [ a [ class "nav-link", href "#/register" ] [ text "Sign up" ] ]
            ]


view : String -> Maybe Session -> Html msg
view appName session =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ href "#/", class "navbar-brand" ]
                [ text (String.toLower appName) ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                ([ li [ class "nav-item" ]
                    [ a [ class "nav-link active", href "#/" ] [ text "Home" ] ]
                 ]
                    ++ (navigation session)
                )
            ]
        ]
