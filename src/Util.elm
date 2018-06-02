module Util exposing (formatDate, isLoggedIn, viewArticleList)

import Html exposing (Html, div, text, button, a, ul, li, img, span, i, h1, p)
import Html.Attributes exposing (class, href, src)
import RemoteData exposing (WebData)
import Date exposing (Date)
import Date.Format
import Model exposing (Session, Articles, Article)


formatDate : Date -> String
formatDate date =
    Date.Format.format "%B %e, %Y" date


isLoggedIn : Maybe Session -> Bool
isLoggedIn session =
    case session of
        Just _ ->
            True

        Nothing ->
            False


viewArticleList : WebData Articles -> Html msg
viewArticleList articles =
    case articles of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div [ class "article-preview" ] [ text "Loading articles..." ]

        RemoteData.Success articles ->
            if List.length articles.articles == 0 then
                div [ class "article-preview" ]
                    [ text "No articles here... yet." ]
            else
                div [] (articles.articles |> List.map viewArticlePreview)

        RemoteData.Failure error ->
            text (toString error)


viewArticlePreview : Article -> Html msg
viewArticlePreview article =
    let
        authorImg =
            if not (String.isEmpty article.author.image) then
                img [ src article.author.image ] []
            else
                img [] []
    in
        div
            [ class "article-preview" ]
            [ div [ class "article-meta" ]
                [ a [ href ("#/profile/" ++ article.author.username) ]
                    [ authorImg ]
                , div [ class "info" ]
                    [ a [ class "author", href ("#/profile/" ++ article.author.username) ] [ text article.author.username ]
                    , span [ class "date" ]
                        [ text (formatDate article.createdAt) ]
                    ]
                , div [ class "pull-xs-right" ]
                    [ button [ class "btn btn-sm btn-outline-primary" ]
                        [ i [ class "ion-heart" ] []
                        , text (" " ++ toString article.favoritesCount)
                        ]
                    ]
                ]
            , a [ class "preview-link", href ("/#/article/" ++ article.slug) ]
                [ h1 [] [ text article.title ]
                , p [] [ text article.description ]
                , span [] [ text "Read more..." ]
                , ul [ class "tag-list" ]
                    (List.map
                        (\tag -> (li [ class "tag-default tag-pill tag-outline" ] [ text tag ]))
                        article.tagList
                    )
                ]
            ]
