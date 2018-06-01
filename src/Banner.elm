module Banner exposing (view)

import Html exposing (Html, div, text, h1, p, a, span, button, img, i)
import Html.Attributes exposing (class, href, src)
import Model exposing (Article)
import Util exposing (formatDate)


viewArticle : Article -> Html msg
viewArticle article =
    div [ class "container" ]
        [ h1 [] [ text article.title ]
        , div
            [ class "article-meta" ]
            [ a [ href "" ]
                [ img [ src article.author.image ] [] ]
            , div [ class "info" ]
                [ a [ class "author", href "" ]
                    [ text article.author.username ]
                , span [ class "date" ]
                    [ text (formatDate article.createdAt) ]
                ]
            , button [ class "btn btn-sm btn-outline-secondary" ]
                [ i [ class "ion-plus-round" ]
                    []
                , text (" Follow " ++ article.author.username)
                ]
            , text " "
            , button [ class "btn btn-sm btn-outline-primary" ]
                [ i [ class "ion-heart" ]
                    []
                , text " Favorite Article "
                , span [ class "counter" ]
                    [ text ("(" ++ (toString article.favoritesCount) ++ ")") ]
                ]
            ]
        ]


view : Maybe Article -> Html msg
view article =
    div
        [ class "banner" ]
        [ case article of
            Just article ->
                viewArticle article

            Nothing ->
                div [ class "container" ]
                    [ h1 [ class "logo-font" ] [ text "conduit" ]
                    , p [] [ text "A place to share your knowledge." ]
                    ]
        ]
