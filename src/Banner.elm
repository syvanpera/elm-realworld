module Banner exposing (render)

import Html exposing (Html, div, text, h1, p)
import Html.Attributes exposing (class)


render : String -> Html msg
render appName =
    div
        [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ]
                [ text (String.toLower appName) ]
            , p [] [ text "A place to share your knowledge." ]
            ]
        ]
