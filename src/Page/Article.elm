module Page.Article exposing (Model, Msg, initialModel, init, view, update)

import Html exposing (Html, div, text, h2, a, button, hr, p, i, span, img, form, textarea)
import Html.Attributes exposing (class, href, src, id, placeholder, attribute)
import RemoteData exposing (WebData)
import Model exposing (Article, Slug)
import Api exposing (fetchArticle)
import Util exposing (formatDate)
import Banner


type alias Model =
    { article : WebData Article
    }


type Msg
    = NoOp
    | FetchArticle Slug
    | OnFetchArticle (WebData Article)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked


init : Slug -> ( Model, Cmd Msg )
init slug =
    ( { initialModel | article = RemoteData.Loading }
    , fetchArticle slug |> Cmd.map OnFetchArticle
    )


viewArticle : Article -> Html msg
viewArticle article =
    div [ class "container page" ]
        [ div [ class "row article-content" ]
            [ div [ class "col-md-12" ]
                [ p []
                    [ text "Web development technologies have evolved at an incredible clip over the past few years." ]
                , h2 [ id "introducing-ionic" ]
                    [ text "Introducing RealWorld." ]
                , p []
                    [ text "It's a great solution for learning how other frameworks work." ]
                ]
            ]
        , hr []
            []
        , div [ class "article-actions" ]
            [ div [ class "article-meta" ]
                [ a [ href "" ]
                    [ img [ src article.author.image ]
                        []
                    ]
                , div [ class "info" ]
                    [ a [ class "author", href "" ]
                        [ text article.author.username ]
                    , span [ class "date" ]
                        [ text (formatDate article.createdAt) ]
                    ]
                , button [ class "btn btn-sm btn-outline-secondary" ]
                    [ i [ class "ion-plus-round" ]
                        []
                    , text (" Follow " ++ article.author.username ++ " ")
                    ]
                , text " "
                , button [ class "btn btn-sm btn-outline-primary" ]
                    [ i [ class "ion-heart" ]
                        []
                    , text " Favorite Post "
                    , span [ class "counter" ]
                        [ text ("(" ++ (toString article.favoritesCount) ++ ")") ]
                    ]
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                [ form [ class "card comment-form" ]
                    [ div [ class "card-block" ]
                        [ textarea [ class "form-control", placeholder "Write a comment...", attribute "rows" "3" ]
                            []
                        ]
                    , div [ class "card-footer" ]
                        [ img [ class "comment-author-img", src "http://i.imgur.com/Qr71crq.jpg" ]
                            []
                        , button [ class "btn btn-sm btn-primary" ]
                            [ text "Post Comment" ]
                        ]
                    ]
                , div [ class "card" ]
                    [ div [ class "card-block" ]
                        [ p [ class "card-text" ]
                            [ text "With supporting text below as a natural lead-in to additional content." ]
                        ]
                    , div [ class "card-footer" ]
                        [ a [ class "comment-author", href "" ]
                            [ img [ class "comment-author-img", src "http://i.imgur.com/Qr71crq.jpg" ] [] ]
                        , text " "
                        , a [ class "comment-author", href "" ]
                            [ text "Jacob Schmidt" ]
                        , span [ class "date-posted" ]
                            [ text "Dec 29th" ]
                        ]
                    ]
                , div [ class "card" ]
                    [ div [ class "card-block" ]
                        [ p [ class "card-text" ]
                            [ text "With supporting text below as a natural lead-in to additional content." ]
                        ]
                    , div [ class "card-footer" ]
                        [ a [ class "comment-author", href "" ]
                            [ img [ class "comment-author-img", src "http://i.imgur.com/Qr71crq.jpg" ] [] ]
                        , text " "
                        , a [ class "comment-author", href "" ]
                            [ text "Jacob Schmidt" ]
                        , span [ class "date-posted" ]
                            [ text "Dec 29th" ]
                        , span [ class "mod-options" ]
                            [ i [ class "ion-edit" ] []
                            , i [ class "ion-trash-a" ] []
                            ]
                        ]
                    ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "article-page" ]
        (case model.article of
            RemoteData.Success article ->
                [ Banner.view (Just article)
                , div [] [ text (toString model) ]
                , viewArticle article
                ]

            _ ->
                []
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchArticle slug ->
            ( { model | article = RemoteData.Loading }
            , fetchArticle slug |> Cmd.map OnFetchArticle
            )

        OnFetchArticle response ->
            ( { model | article = response }, Cmd.none )
