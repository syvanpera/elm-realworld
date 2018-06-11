module Page.Article exposing (Model, Msg, init, view, update)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)
import Api.Article exposing (fetchArticle, fetchComments)
import Data.Article exposing (Article, Comments, Slug)
import Data.Session exposing (Session)
import Views.Article as ArticleView
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


view : Maybe Session -> Model -> Html Msg
view session model =
    div [ class "article-page" ]
        (case model.article of
            RemoteData.Success article ->
                [ Banner.view (Just article)
                , ArticleView.view session article model.comments
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
