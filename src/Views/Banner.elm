module Views.Banner exposing (view)

import Html exposing (Html, div, text, h1, p)
import Html.Attributes exposing (class)
import Data.Article exposing (Article)
import Views.Article as ArticleView exposing (ViewType(..), viewArticleMeta)


viewArticle : Article -> Html msg
viewArticle article =
    div [ class "container" ]
        [ h1 [] [ text article.title ]
        , viewArticleMeta ArticleView.Details article
        ]


view : Maybe Article -> Html msg
view article =
    div [ class "banner" ]
        [ case article of
            Just article ->
                viewArticle article

            Nothing ->
                div [ class "container" ]
                    [ h1 [ class "logo-font" ] [ text "conduit" ]
                    , p [] [ text "A place to share your knowledge." ]
                    ]
        ]
