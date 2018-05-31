module Page.Home exposing (Model, Msg, initialModel, init, view, update)

import Html exposing (Html, div, text, button, a, ul, li, img, span, i, h1, p)
import Html.Attributes exposing (class, href, src, hidden)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Model exposing (Articles, Article, Tags, Tag)
import Api exposing (fetchArticles, fetchTags)
import Util exposing (formatDate)
import Banner
import Debug


type alias Model =
    { articles : WebData Articles
    , tags : WebData Tags
    , tagFilter : Maybe Tag
    }


type Msg
    = NoOp
    | FetchArticles
    | FilterWithTag (Maybe Tag)
    | OnFetchArticles (WebData Articles)
    | OnFetchTags (WebData Tags)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked Nothing


init : ( Model, Cmd Msg )
init =
    ( { initialModel | articles = RemoteData.Loading, tags = RemoteData.Loading }
    , Cmd.batch
        [ fetchArticles 0 Nothing |> Cmd.map OnFetchArticles
        , fetchTags |> Cmd.map OnFetchTags
        ]
    )


articlePreview : Article -> Html msg
articlePreview article =
    let
        authorImg =
            if not (String.isEmpty article.author.image) then
                img [ src article.author.image ] []
            else
                img [] []
    in
        div
            [ class "article-preview" ]
            [ div [ class "article-meta" ]
                [ a [ href "" ]
                    [ authorImg ]
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
            , a [ class "preview-link", href ("/#/article/" ++ article.slug) ]
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


articleList : WebData Articles -> Html msg
articleList articles =
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


tagList : WebData Tags -> List (Html Msg)
tagList tagsData =
    case tagsData of
        RemoteData.NotAsked ->
            [ text "" ]

        RemoteData.Loading ->
            [ text "Loading tags..." ]

        RemoteData.Success tags ->
            tags.tags |> List.map (\tag -> a [ href "javascript:void(0)", class "tag-pill tag-default", onClick (FilterWithTag (Just tag)) ] [ text tag ])

        RemoteData.Failure _ ->
            [ text "" ]


view : Model -> Html Msg
view model =
    div [ class "home-page" ]
        [ Banner.view Nothing
        , div
            [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ]
                    [ div [ class "feed-toggle" ]
                        [ ul [ class "nav nav-pills outline-active" ]
                            [ li [ class "nav-item" ]
                                [ a
                                    [ href "javascript:void(0)"
                                    , class
                                        ("nav-link"
                                            ++ (if model.tagFilter == Nothing then
                                                    " active"
                                                else
                                                    ""
                                               )
                                        )
                                    , onClick (FilterWithTag Nothing)
                                    ]
                                    [ text "Global Feed" ]
                                ]
                            , li [ class "nav-item", hidden (model.tagFilter == Nothing) ]
                                [ a [ href "javascript:void(0)", class "nav-link active" ]
                                    [ i [ class "ion-pound" ] []
                                    , text (" " ++ (Maybe.withDefault "" model.tagFilter))
                                    ]
                                ]
                            ]
                        ]
                    , articleList model.articles
                    ]
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar", hidden (model.tags == RemoteData.NotAsked) ]
                        [ p [ hidden (model.tags == RemoteData.Loading) ] [ text "Popular Tags" ]
                        , div [ class "tag-list" ]
                            (tagList model.tags)
                        ]
                    ]
                ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchArticles ->
            ( { model | articles = RemoteData.Loading, tags = RemoteData.Loading }
            , Cmd.batch
                [ fetchArticles 0 Nothing |> Cmd.map OnFetchArticles
                , fetchTags |> Cmd.map OnFetchTags
                ]
            )

        FilterWithTag tag ->
            case tag of
                Just tag ->
                    ( { model | tagFilter = Just tag, articles = RemoteData.Loading }
                    , fetchArticles 0 (Just tag) |> Cmd.map OnFetchArticles
                    )

                Nothing ->
                    ( { model | tagFilter = Nothing, articles = RemoteData.Loading }
                    , fetchArticles 0 Nothing |> Cmd.map OnFetchArticles
                    )

        OnFetchArticles response ->
            ( { model | articles = response }, Cmd.none )

        OnFetchTags response ->
            ( { model | tags = response }, Cmd.none )
