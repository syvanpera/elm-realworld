module Page.Home exposing (Model, Msg, initialModel, init, view, update)

import Html exposing (Html, div, text, a, ul, li, i, p)
import Html.Attributes exposing (class, href, hidden)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Model exposing (Articles, Tags, Tag, Session)
import Api exposing (fetchArticles, fetchTags, fetchFeed)
import Util exposing (isLoggedIn)
import Views.Feed exposing (viewFeed)
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
    = ActiveFeed Feed
    | FetchArticlesResponse (WebData Articles)
    | FetchTagsResponse (WebData Tags)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked Global


init : ( Model, Cmd Msg )
init =
    ( { initialModel | articles = RemoteData.Loading, tags = RemoteData.Loading }
    , Cmd.batch
        [ fetchArticles 0 10 Nothing |> Cmd.map FetchArticlesResponse
        , fetchTags |> Cmd.map FetchTagsResponse
        ]
    )


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
                            [ href "javascript:void(0)"
                            , class "tag-pill tag-default"
                            , onClick (ActiveFeed (Tagged tag))
                            ]
                            [ text tag ]
                    )

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
            [ li [ class "nav-item", hidden (not <| isLoggedIn session) ]
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
                    , viewFeed model.articles
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


update : Msg -> Model -> Maybe Session -> ( Model, Cmd Msg )
update msg model session =
    case msg of
        ActiveFeed feed ->
            case feed of
                Personal ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchFeed 0 session |> Cmd.map FetchArticlesResponse
                    )

                Global ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchArticles 0 10 Nothing |> Cmd.map FetchArticlesResponse
                    )

                Tagged tag ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchArticles 0 10 (Just tag) |> Cmd.map FetchArticlesResponse
                    )

        FetchArticlesResponse response ->
            ( { model | articles = response }, Cmd.none )

        FetchTagsResponse response ->
            ( { model | tags = response }, Cmd.none )
