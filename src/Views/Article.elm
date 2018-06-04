module Views.Article exposing (ViewType(..), viewArticleMeta)

import Html exposing (Html, div, text, button, a, img, span, i)
import Html.Attributes exposing (class, href, src)
import Model exposing (Article)
import Util exposing (formatDate)


type ViewType
    = Default
    | Compact


viewDefault : Article -> List (Html msg)
viewDefault article =
    [ button [ class "btn btn-sm btn-outline-secondary" ]
        [ i [ class "ion-plus-round" ] []
        , text (" Follow " ++ article.author.username ++ " ")
        ]
    , text " "
    , button [ class "btn btn-sm btn-outline-primary" ]
        [ i [ class "ion-heart" ] []
        , text " Favorite Article "
        , span [ class "counter" ]
            [ text ("(" ++ toString article.favoritesCount ++ ")") ]
        ]
    ]


viewCompact : Article -> List (Html msg)
viewCompact article =
    [ div [ class "pull-xs-right" ]
        [ button [ class "btn btn-sm btn-outline-primary" ]
            [ i [ class "ion-heart" ] []
            , text (" " ++ toString article.favoritesCount)
            ]
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

        opView =
            if viewType == Compact then
                viewCompact
            else
                viewDefault
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
                (opView article)
            )
