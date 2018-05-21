module Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)


view : String -> Html msg
view appName =
    footer []
        [ div [ class "container" ]
            [ a [ href "/", class "logo-font" ] [ text (String.toLower appName) ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from "
                , a [ href "https://thinkster.io" ] [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]
