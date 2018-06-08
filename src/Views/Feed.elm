module Views.Feed exposing (viewFeed)

import Html exposing (Html, div, text, a, ul, li, span, h1, p)
import Html.Attributes exposing (class, href)
import RemoteData exposing (WebData)
import Data.Article exposing (Article)
import Data.Feed exposing (Feed)
import Views.Article as ArticleView exposing (ViewType(..), viewArticleMeta)


viewFeed : WebData Feed -> Html msg
viewFeed articlesData =
    case articlesData of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div [ class "article-preview" ] [ text "Loading articles..." ]

        RemoteData.Success articles ->
            if List.length articles.articles == 0 then
                div [ class "article-preview" ]
                    [ text "No articles here... yet." ]
            else
                div [] (articles.articles |> List.map viewPreview)

        RemoteData.Failure error ->
            text (toString error)


viewPreview : Article -> Html msg
viewPreview article =
    div
        [ class "article-preview" ]
        [ viewArticleMeta ArticleView.Compact article
        , a [ class "preview-link", href ("/#/article/" ++ article.slug) ]
            [ h1 [] [ text article.title ]
            , p [] [ text article.description ]
            , span [] [ text "Read more..." ]
            , ul [ class "tag-list" ]
                (List.map
                    (\tag -> li [ class "tag-default tag-pill tag-outline" ] [ text tag ])
                    article.tagList
                )
            ]
        ]
