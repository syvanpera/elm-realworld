module Page.Home exposing (Model, Msg, initialModel, init, view, update)

import Html exposing (Html, div, text, button, a, ul, li, img, span, i, h1, p)
import Html.Attributes exposing (class, href, src, hidden)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Model exposing (Articles, Article, Tags, Tag, Session)
import Api exposing (fetchArticles, fetchTags)
import Util exposing (formatDate)
import Banner
import Debug


type alias Model =
    { articles : WebData Articles
    , tags : WebData Tags
    , activeFeed : Feed
    }


type Feed
    = Global
    | Personal
    | Tagged Tag


type Msg
    = NoOp
    | FetchArticles
    | ActiveFeed Feed
    | FetchArticlesResponse (WebData Articles)
    | FetchTagsResponse (WebData Tags)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked Global


init : ( Model, Cmd Msg )
init =
    ( { initialModel | articles = RemoteData.Loading, tags = RemoteData.Loading }
    , Cmd.batch
        [ fetchArticles 0 Nothing |> Cmd.map FetchArticlesResponse
        , fetchTags |> Cmd.map FetchTagsResponse
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
            tags.tags |> List.map (\tag -> a [ href "javascript:void(0)", class "tag-pill tag-default", onClick (ActiveFeed (Tagged tag)) ] [ text tag ])

        RemoteData.Failure _ ->
            [ text "" ]


viewFeeds : Maybe Session -> Model -> Html Msg
viewFeeds session model =
    let
        activeFeedTag =
            case model.activeFeed of
                Tagged tag ->
                    tag

                _ ->
                    ""
    in
        ul [ class "nav nav-pills outline-active" ]
            [ li [ class "nav-item", hidden (session == Nothing) ]
                [ a
                    [ href "javascript:void(0)"
                    , class
                        ("nav-link"
                            ++ (if model.activeFeed == Personal then
                                    " active"
                                else
                                    ""
                               )
                        )
                    , onClick (ActiveFeed Personal)
                    ]
                    [ text "Your Feed" ]
                ]
            , li [ class "nav-item" ]
                [ a
                    [ href "javascript:void(0)"
                    , class
                        ("nav-link"
                            ++ (if model.activeFeed == Global then
                                    " active"
                                else
                                    ""
                               )
                        )
                    , onClick (ActiveFeed Global)
                    ]
                    [ text "Global Feed" ]
                ]
            , li [ class "nav-item", hidden (model.activeFeed == Global || model.activeFeed == Personal) ]
                [ a [ href "javascript:void(0)", class "nav-link active" ]
                    [ i [ class "ion-pound" ] []
                    , text (" " ++ activeFeedTag)
                    ]
                ]
            ]


view : Maybe Session -> Model -> Html Msg
view session model =
    div [ class "home-page" ]
        [ Banner.view Nothing
        , div
            [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ]
                    [ div [ class "feed-toggle" ] [ viewFeeds session model ]
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
                [ fetchArticles 0 Nothing |> Cmd.map FetchArticlesResponse
                , fetchTags |> Cmd.map FetchTagsResponse
                ]
            )

        ActiveFeed feed ->
            case feed of
                Personal ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchArticles 0 Nothing |> Cmd.map FetchArticlesResponse
                    )

                Global ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchArticles 0 Nothing |> Cmd.map FetchArticlesResponse
                    )

                Tagged tag ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchArticles 0 (Just tag) |> Cmd.map FetchArticlesResponse
                    )

        FetchArticlesResponse response ->
            ( { model | articles = response }, Cmd.none )

        FetchTagsResponse response ->
            ( { model | tags = response }, Cmd.none )
