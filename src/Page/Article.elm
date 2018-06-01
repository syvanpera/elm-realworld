module Page.Article exposing (Model, Msg, initialModel, init, view, update)

import Html exposing (Html, div, text, h2, a, button, hr, p, i, span, img, form, textarea, ul, li)
import Html.Attributes exposing (class, href, src, id, placeholder, attribute, hidden)
import RemoteData exposing (WebData)
import Markdown
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
    | FetchArticleResponse (WebData Article)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked


init : Slug -> ( Model, Cmd Msg )
init slug =
    ( { initialModel | article = RemoteData.Loading }
    , fetchArticle slug |> Cmd.map FetchArticleResponse
    )


viewArticle : Article -> Html msg
viewArticle article =
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
                    , text " Favorite Article "
                    , span [ class "counter" ]
                        [ text ("(" ++ (toString article.favoritesCount) ++ ")") ]
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
            , fetchArticle slug |> Cmd.map FetchArticleResponse
            )

        FetchArticleResponse response ->
            ( { model | article = response }, Cmd.none )
