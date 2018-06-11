module Views.Comments exposing (view)

import Html exposing (Html, form, div, a, text, textarea, img, button, span, p)
import Html.Attributes exposing (class, attribute, placeholder, href, src)
import RemoteData exposing (WebData)
import Data.Article exposing (Comments, Comment)
import Data.Session exposing (Session)
import Util exposing (formatDate)


viewCommentForm : Maybe Session -> Html msg
viewCommentForm session =
    case session of
        Just _ ->
            form [ class "card comment-form" ]
                [ div [ class "card-block" ]
                    [ textarea [ class "form-control", placeholder "write a comment...", attribute "rows" "3" ] [] ]
                , div [ class "card-footer" ]
                    [ img [ class "comment-author-img", src "http://i.imgur.com/qr71crq.jpg" ] []
                    , button [ class "btn btn-sm btn-primary" ]
                        [ text "post comment" ]
                    ]
                ]

        Nothing ->
            p []
                [ a [ href "#/login" ] [ text "Sign in" ]
                , text " or "
                , a [ href "#/register" ] [ text "sign up" ]
                , text " to add comments on this article."
                ]


viewCommentCard : Comment -> Html msg
viewCommentCard comment =
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ p [ class "card-text" ]
                [ text comment.body ]
            ]
        , div [ class "card-footer" ]
            [ a [ class "comment-author", href ("#/@" ++ comment.author.username) ]
                [ img [ class "comment-author-img", src comment.author.image ] [] ]
            , a [ class "comment-author", href ("#/@" ++ comment.author.username) ]
                [ text comment.author.username ]
            , span [ class "date-posted" ] [ text (formatDate comment.createdAt) ]
            ]
        ]


view : Maybe Session -> WebData Comments -> List (Html msg)
view session commentsData =
    (viewCommentForm session
        :: (case commentsData of
                RemoteData.Success comments ->
                    List.map viewCommentCard comments.comments

                _ ->
                    []
           )
    )
