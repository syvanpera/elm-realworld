module Page.Article exposing (Model, Msg, initialModel, init, view, update)

import Html exposing (Html, div, text, h2, a, button, hr, p, i, span, img, form, textarea, ul, li)
import Html.Attributes exposing (class, href, src, id, placeholder, attribute, hidden)
import RemoteData exposing (WebData)
import Markdown
import Model exposing (Article, Comments, Comment, Slug, Session)
import Api exposing (fetchArticle, fetchComments)
import Util exposing (formatDate)
import Banner


type alias Model =
    { article : WebData Article
    , comments : WebData Comments
    }


type Msg
    = NoOp
    | FetchArticleResponse (WebData Article)
    | FetchCommentsResponse (WebData Comments)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked


init : Slug -> ( Model, Cmd Msg )
init slug =
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
viewArticle session article comments =
    div [ class "container page" ]
        [ div [ class "row article-content" ]
            [ div [ class "col-md-12" ]
                [ Markdown.toHtml [] article.body
                , ul [ class "tag-list", hidden (List.isEmpty article.tagList) ]
                    (List.map
                        (\tag ->
                            li [ class "tag-default tag-pill tag-outline" ] [ text tag ]
                        )
                        article.tagList
                    )
                ]
            ]
        , hr []
            []
        , div [ class "article-actions" ]
            [ div [ class "article-meta" ]
                [ a [ href ("#/@" ++ article.author.username) ]
                    [ img [ src article.author.image ] [] ]
                , div [ class "info" ]
                    [ a [ class "author", href ("#/@" ++ article.author.username) ]
                        [ text article.author.username ]
                    , span [ class "date" ]
                        [ text (formatDate article.createdAt) ]
                    ]
                , button [ class "btn btn-sm btn-outline-secondary" ]
                    [ i [ class "ion-plus-round" ] []
                    , text (" Follow " ++ article.author.username ++ " ")
                    ]
                , text " "
                , button [ class "btn btn-sm btn-outline-primary" ]
                    [ i [ class "ion-heart" ] []
                    , text " Favorite Article "
                    , span [ class "counter" ]
                        [ text ("(" ++ (toString article.favoritesCount) ++ ")") ]
                    ]
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                (viewCommentForm session
                    :: (case comments of
                            RemoteData.Success comments ->
                                List.map viewCommentCard comments.comments

                            _ ->
                                []
                       )
                )
            ]
        ]


view : Model -> Maybe Session -> Html Msg
view model session =
    div [ class "article-page" ]
        (case model.article of
            RemoteData.Success article ->
                [ Banner.view (Just article)
                , viewArticle session article model.comments
                ]

            _ ->
                []
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchArticleResponse response ->
            ( { model | article = response }, Cmd.none )

        FetchCommentsResponse response ->
            ( { model | comments = response }, Cmd.none )
