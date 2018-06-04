module Banner exposing (view)

import Html exposing (Html, div, text, h1, p)
import Html.Attributes exposing (class)
import Model exposing (Article)
import Views.Article as ArticleView exposing (ViewType(..), viewArticleMeta)


viewArticle : Article -> Html msg
viewArticle article =
    div [ class "container" ]
        [ h1 [] [ text article.title ]
        , viewArticleMeta ArticleView.Default article
        ]


view : Maybe Article -> Html msg
view maybeArticle =
    div
        [ class "banner" ]
        [ case maybeArticle of
            Just article ->
                viewArticle article

            Nothing ->
                div [ class "container" ]
                    [ h1 [ class "logo-font" ] [ text "conduit" ]
                    , p [] [ text "A place to share your knowledge." ]
                    ]
        ]
