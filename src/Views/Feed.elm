module Views.Feed exposing (view)

import Html exposing (Html, div, text, a, ul, li, span, h1, p)
import Html.Attributes exposing (class, classList, href)
import RemoteData exposing (WebData)
import Data.Article exposing (Article)
import Data.Feed exposing (Feed)
import Views.Article as ArticleView exposing (ViewType(..), viewArticleMeta)
import Debug


viewPreview : Article -> Html msg
viewPreview article =
    div
        [ class "article-preview" ]
        [ viewArticleMeta ArticleView.List article
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


pagination : Int -> Int -> Feed -> Html msg
pagination currentPage articlesPerPage articles =
    let
        pages =
            articles.articlesCount // articlesPerPage

        pageLink page isActive =
            li [ classList [ ( "page-item", True ), ( "active", isActive ) ] ]
                [ a [ class "page-link", href "" ] [ text (toString page) ]
                ]
    in
        List.range 1 pages
            |> List.map (\page -> pageLink page (page == currentPage))
            |> ul [ class "pagination" ]


view : Int -> Int -> WebData Feed -> Html msg
view currentPage articlesPerPage articlesData =
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
                div []
                    [ div [] (articles.articles |> List.map viewPreview)
                    , pagination currentPage articlesPerPage articles
                    ]

        RemoteData.Failure error ->
            text (toString error)
