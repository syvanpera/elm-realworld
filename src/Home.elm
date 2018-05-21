module Home exposing (view)

import Html exposing (..)
import Date
import Html.Attributes exposing (class, href, src)
import RemoteData exposing (WebData)
import Models exposing (Articles, Article, Tags)


formatDate : String -> String
formatDate dateStr =
    let
        dateResult =
            Date.fromString dateStr
    in
        case dateResult of
            Ok date ->
                (toString (Date.month date))
                    ++ " "
                    ++ (toString (Date.day date))
                    ++ ", "
                    ++ (toString (Date.year date))

            Err _ ->
                ""


articlePreview : Article -> Html msg
articlePreview article =
    div
        [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ href "" ]
                [ img [ src article.author.image ] [] ]
            , div [ class "info" ]
                [ a [ class "author", href "" ] [ text article.author.username ]
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
        , a [ class "preview-link", href ("/#/articles/" ++ article.slug) ]
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


maybeArticleList : WebData Articles -> Html msg
maybeArticleList articles =
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
                div [] (articles.articles |> List.map articlePreview)

        RemoteData.Failure error ->
            text (toString error)


maybeTagList : WebData Tags -> List (Html msg)
maybeTagList tagsData =
    case tagsData of
        RemoteData.NotAsked ->
            [ text "" ]

        RemoteData.Loading ->
            [ text "Loading tags..." ]

        RemoteData.Success tags ->
            tags.tags |> List.map (\tag -> a [ href "", class "tag-pill tag-default" ] [ text tag ])

        RemoteData.Failure _ ->
            [ text "" ]


view : WebData Tags -> WebData Articles -> Html msg
view tags articles =
    div [ class "container page" ]
        [ div [ class "row" ]
            [ div [ class "col-md-9" ]
                [ div [ class "feed-toggle" ]
                    [ ul [ class "nav nav-pills outline-active" ]
                        [ li [ class "nav-item" ]
                            [ a [ href "", class "nav-link active" ]
                                [ text "Global Feed" ]
                            ]
                        ]
                    ]
                , maybeArticleList articles
                ]
            , div [ class "col-md-3" ]
                [ div [ class "sidebar" ]
                    [ p [] [ text "Popular Tags" ]
                    , div [ class "tag-list" ]
                        (maybeTagList tags)
                    ]
                ]
            ]
        ]
