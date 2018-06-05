module Views.Article exposing (ViewType(..), viewArticleMeta)

import Html exposing (Html, div, text, button, a, img, span, i)
import Html.Attributes exposing (class, href, src)
import Model exposing (Article)
import Util exposing (formatDate)
import Views.Profile exposing (viewFollowButton)


type ViewType
    = Default
    | Compact


viewProfileActions : ViewType -> Article -> List (Html msg)
viewProfileActions viewType article =
    if viewType == Compact then
        [ div [ class "pull-xs-right" ]
            [ button [ class "btn btn-sm btn-outline-primary" ]
                [ i [ class "ion-heart" ] []
                , text (" " ++ toString article.favoritesCount)
                ]
            ]
        ]
    else
        [ viewFollowButton article.author
        , text " "
        , button [ class "btn btn-sm btn-outline-primary" ]
            [ i [ class "ion-heart" ] []
            , text " Favorite Article "
            , span [ class "counter" ]
                [ text ("(" ++ toString article.favoritesCount ++ ")") ]
            ]
        ]


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
