module Views.Article exposing (ViewType(..), view, viewArticleMeta)

import Html exposing (Html, div, text, button, a, img, span, i, li, ul, hr)
import Html.Attributes exposing (class, classList, href, src, hidden)
import RemoteData exposing (WebData)
import Markdown
import Data.Article exposing (Article, Comments)
import Data.Session exposing (Session)
import Views.Comments as Comments
import Views.Profile exposing (viewFollowButton)
import Util exposing (toggleText, formatDate)


type ViewType
    = Details
    | List


favoriteButton : Article -> Bool -> Html msg
favoriteButton { favorited, favoritesCount } isCompact =
    button
        [ class "btn btn-sm"
        , classList
            [ ( "btn-outline-primary", not favorited )
            , ( "btn-primary", favorited )
            ]
        ]
        (if isCompact then
            [ i [ class "ion-heart" ] []
            , text (" " ++ toString favoritesCount)
            ]
         else
            [ i [ class "ion-heart" ] []
            , text (toggleText favorited "Unfavorite" "Favorite")
            , span [ class "counter" ]
                [ text ("(" ++ toString favoritesCount ++ ")") ]
            ]
        )


viewProfileActions : ViewType -> Article -> List (Html msg)
viewProfileActions viewType article =
    case viewType of
        Details ->
            [ viewFollowButton article.author
            , text " "
            , favoriteButton article False
            ]

        List ->
            [ div [ class "pull-xs-right" ] [ favoriteButton article True ] ]


viewArticleMeta : ViewType -> Article -> Html msg
viewArticleMeta viewType article =
    let
        authorImg =
            if not (String.isEmpty article.author.image) then
                img [ src article.author.image ] []
            else
                img [] []
    in
        div [ class "article-meta" ]
            (List.append
                [ a [ href ("#/profile/" ++ article.author.username) ]
                    [ authorImg ]
                , div [ class "info" ]
                    [ a [ class "author", href ("#/profile/" ++ article.author.username) ]
                        [ text article.author.username ]
                    , span [ class "date" ]
                        [ text (formatDate article.createdAt) ]
                    ]
                ]
                (viewProfileActions viewType article)
            )


view : Maybe Session -> Article -> WebData Comments -> Html msg
view session article comments =
    let
        tagListElement tag =
            li [ class "tag-default tag-pill tag-outline" ] [ text tag ]
    in
        div [ class "container page" ]
            [ div [ class "row article-content" ]
                [ div [ class "col-md-12" ]
                    [ Markdown.toHtml [] article.body
                    , List.map tagListElement article.tagList
                        |> ul [ class "tag-list", hidden (List.isEmpty article.tagList) ]
                    ]
                ]
            , hr []
                []
            , div [ class "article-actions" ]
                [ viewArticleMeta Details article ]
            , div [ class "row" ]
                [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                    (Comments.view session comments)
                ]
            ]
