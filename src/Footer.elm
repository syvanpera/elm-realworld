module Footer exposing (view)

import Html exposing (Html, footer, div, a, text, span)
import Html.Attributes exposing (class, href)


view : Html msg
view =
    footer []
        [ div [ class "container" ]
            [ a [ href "/", class "logo-font" ] [ text "conduit" ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from "
                , a [ href "https://thinkster.io" ] [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]
