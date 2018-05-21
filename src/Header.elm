module Header exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)


navigation : Bool -> List (Html msg)
navigation isLoggedIn =
    if isLoggedIn then
        [ li [ class "nav-item" ]
            [ a [ class "nav-link", href "" ] [ i [ class "ion-compose" ] [], text " New Post" ] ]
        , li [ class "nav-item" ]
            [ a [ class "nav-link", href "" ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ]
        , li [ class "nav-item" ]
            [ a [ class "nav-link", href "" ] [ text "Tinimini" ] ]
        ]
    else
        [ li [ class "nav-item" ]
            [ a [ class "nav-link", href "" ] [ text "Sign in" ] ]
        , li [ class "nav-item" ]
            [ a [ class "nav-link", href "" ] [ text "Sign up" ] ]
        ]


view : String -> Bool -> Html msg
view appName isLoggedIn =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand" ]
                [ text (String.toLower appName) ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                ([ li [ class "nav-item" ]
                    [ a [ class "nav-link active", href "" ] [ text "Home" ] ]
                 ]
                    ++ (navigation isLoggedIn)
                )
            ]
        ]
