module Page.Home exposing (Model, Msg, init, view, update)

import Html exposing (Html, div, text, a, ul, li, i, p)
import Html.Attributes exposing (class, classList, href, hidden)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Util exposing (validSession)
import Api.Article exposing (fetchTags)
import Api.Feed exposing (fetchFeed, fetchPrivateFeed, fetchFavoriteFeed)
import Data.Article exposing (Tags, Tag)
import Data.Feed exposing (Feed)
import Data.Session exposing (Session)
import Views.Feed as Feed
import Views.Banner as Banner


type alias Model =
    { articles : WebData Feed
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
    | FetchFeedResponse (WebData Feed)
    | FetchTagsResponse (WebData Tags)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked Global 1


init : Maybe Session -> ( Model, Cmd Msg )
init session =
    ( { initialModel | articles = RemoteData.Loading, tags = RemoteData.Loading }
    , Cmd.batch
        [ fetchFeed 0 (articlesPerPage initialModel.activeFeed) Nothing session
            |> Cmd.map FetchFeedResponse
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


availableFeeds : Maybe Session -> Model -> Html Msg
availableFeeds session { activeFeed } =
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
                        [ div [ class "feed-toggle" ] [ availableFeeds session model ]
                        , Feed.view model.currentPage (articlesPerPage model.activeFeed) model.articles
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
                    , articles |> Cmd.map FetchFeedResponse
                    )

                articleLimit =
                    articlesPerPage feed
            in
                case feed of
                    Personal ->
                        updateFeed (fetchPrivateFeed 0 articleLimit session)

                    Global ->
                        updateFeed (fetchFeed 0 articleLimit Nothing session)

                    Tagged tag ->
                        updateFeed (fetchFeed 0 articleLimit (Just tag) session)

                    Favorite username ->
                        updateFeed (fetchFavoriteFeed 0 articleLimit username session)

                    Author username ->
                        updateFeed (fetchPrivateFeed 0 articleLimit session)

        FetchFeedResponse response ->
            ( { model | articles = response }, Cmd.none )

        FetchTagsResponse response ->
            ( { model | tags = response }, Cmd.none )
