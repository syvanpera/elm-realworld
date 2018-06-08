module Page.Home exposing (Model, Msg, init, view, update)

import Html exposing (Html, div, text, a, ul, li, i, p)
import Html.Attributes exposing (class, classList, href, hidden)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Model exposing (Articles, Tags, Tag, Session)
import Api exposing (fetchArticles, fetchFavoriteArticles, fetchTags, fetchFeed)
import Util exposing (validSession)
import Views.Feed exposing (viewFeed)
import Views.Banner as Banner
import Debug


type alias Model =
    { articles : WebData Articles
    , tags : WebData Tags
    , activeFeed : FeedSource
    , currentPage : Int
    }


type FeedSource
    = Global
    | Personal
    | Tagged Tag
    | Favorite String
    | Author String


type Msg
    = ActiveFeed FeedSource
    | FetchArticlesResponse (WebData Articles)
    | FetchTagsResponse (WebData Tags)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked Global 1


init : Maybe Session -> ( Model, Cmd Msg )
init _ =
    ( { initialModel | articles = RemoteData.Loading, tags = RemoteData.Loading }
    , Cmd.batch
        [ fetchArticles 0 (articlesPerPage initialModel.activeFeed) Nothing
            |> Cmd.map FetchArticlesResponse
        , fetchTags
            |> Cmd.map FetchTagsResponse
        ]
    )


articlesPerPage : FeedSource -> Int
articlesPerPage feedSource =
    case feedSource of
        Global ->
            10

        Personal ->
            10

        Tagged _ ->
            10

        Favorite _ ->
            5

        Author _ ->
            5


tagList : WebData Tags -> List (Html Msg)
tagList tagsData =
    case tagsData of
        RemoteData.NotAsked ->
            [ text "" ]

        RemoteData.Loading ->
            [ text "Loading tags..." ]

        RemoteData.Success tags ->
            tags.tags
                |> List.map
                    (\tag ->
                        a
                            [ href "javascript:void(0);"
                            , class "tag-pill tag-default"
                            , onClick (ActiveFeed (Tagged tag))
                            ]
                            [ text tag ]
                    )

        RemoteData.Failure _ ->
            [ text "" ]


viewFeeds : Maybe Session -> Model -> Html Msg
viewFeeds session { activeFeed } =
    let
        activeFeedTag =
            case activeFeed of
                Tagged tag ->
                    tag

                _ ->
                    ""
    in
        ul [ class "nav nav-pills outline-active" ]
            [ li [ class "nav-item", hidden (not <| validSession session) ]
                [ a
                    [ href "javascript:void(0);"
                    , classList [ ( "nav-link", True ), ( "active", activeFeed == Personal ) ]
                    , onClick (ActiveFeed Personal)
                    ]
                    [ text "Your Feed" ]
                ]
            , li [ class "nav-item" ]
                [ a
                    [ href "javascript:void(0);"
                    , classList [ ( "nav-link", True ), ( "active", activeFeed == Global ) ]
                    , onClick (ActiveFeed Global)
                    ]
                    [ text "Global Feed" ]
                ]
            , li [ class "nav-item", hidden (activeFeed == Global || activeFeed == Personal) ]
                [ a [ href "javascript:void(0);", class "nav-link active" ]
                    [ i [ class "ion-pound" ] []
                    , text (" " ++ activeFeedTag)
                    ]
                ]
            ]


pagination : FeedSource -> Int -> WebData Articles -> Html msg
pagination activeFeed currentPage articles =
    case articles of
        RemoteData.Success articles ->
            let
                pages =
                    articles.articlesCount // articlesPerPage activeFeed

                pageLink page isActive =
                    li [ classList [ ( "page-item", True ), ( "active", isActive ) ] ]
                        [ a [ class "page-link", href "" ] [ text (toString page) ]
                        ]
            in
                List.range 1 pages
                    |> List.map (\page -> pageLink page (page == currentPage))
                    |> ul [ class "pagination" ]

        _ ->
            text ""


view : Maybe Session -> Model -> Html Msg
view session model =
    let
        banner =
            if validSession session then
                text ""
            else
                Banner.view Nothing
    in
        div [ class "home-page" ]
            [ banner
            , div
                [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-9" ]
                        [ div [ class "feed-toggle" ] [ viewFeeds session model ]
                        , viewFeed model.articles
                        , pagination model.activeFeed model.currentPage model.articles
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


update : Maybe Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        ActiveFeed feed ->
            let
                updateFeed articles =
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , articles |> Cmd.map FetchArticlesResponse
                    )

                articleLimit =
                    articlesPerPage feed
            in
                case feed of
                    Personal ->
                        updateFeed (fetchFeed 0 articleLimit session)

                    Global ->
                        updateFeed (fetchArticles 0 articleLimit Nothing)

                    Tagged tag ->
                        updateFeed (fetchArticles 0 articleLimit (Just tag))

                    Favorite username ->
                        updateFeed (fetchFavoriteArticles 0 articleLimit username)

                    Author username ->
                        updateFeed (fetchFeed 0 articleLimit session)

        FetchArticlesResponse response ->
            ( { model | articles = response }, Cmd.none )

        FetchTagsResponse response ->
            ( { model | tags = response }, Cmd.none )
