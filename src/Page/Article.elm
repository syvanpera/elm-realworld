module Page.Article exposing (Model, Msg, init, view, update)

import Html exposing (Html, div, text, a, button, hr, p, span, img, form, textarea, ul, li)
import Html.Attributes exposing (class, href, src, placeholder, attribute, hidden)
import RemoteData exposing (WebData)
import Markdown
import Model exposing (Article, Comments, Comment, Slug, Session)
import Views.Article as ArticleView exposing (ViewType(..), viewArticleMeta)
import Api exposing (fetchArticle, fetchComments)
import Util exposing (formatDate)
import Views.Banner as Banner


type alias Model =
    { article : WebData Article
    , comments : WebData Comments
    }


type Msg
    = FetchArticleResponse (WebData Article)
    | FetchCommentsResponse (WebData Comments)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked


init : Slug -> Maybe Session -> ( Model, Cmd Msg )
init slug _ =
    ( { initialModel | article = RemoteData.Loading, comments = RemoteData.Loading }
    , Cmd.batch
        [ fetchArticle slug |> Cmd.map FetchArticleResponse
        , fetchComments slug |> Cmd.map FetchCommentsResponse
        ]
    )


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


viewArticle : Maybe Session -> Article -> WebData Comments -> Html msg
viewArticle session article commentsData =
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
                [ viewArticleMeta ArticleView.Default article ]
            , div [ class "row" ]
                [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                    (viewCommentForm session
                        :: (case commentsData of
                                RemoteData.Success comments ->
                                    List.map viewCommentCard comments.comments

                                _ ->
                                    []
                           )
                    )
                ]
            ]


view : Maybe Session -> Model -> Html Msg
view session model =
    div [ class "article-page" ]
        (case model.article of
            RemoteData.Success article ->
                [ Banner.view (Just article)
                , viewArticle session article model.comments
                ]

            _ ->
                []
        )


update : Maybe Session -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        FetchArticleResponse response ->
            ( { model | article = response }, Cmd.none )

        FetchCommentsResponse response ->
            ( { model | comments = response }, Cmd.none )
