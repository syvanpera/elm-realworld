module Page.Profile exposing (Model, Msg, init, view, update)

import Html exposing (Html, div, text, p, img, h4, button, ul, li, a, i)
import Html.Attributes exposing (class, src, href)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Model exposing (Profile, Articles, Session)
import Api exposing (fetchProfile, fetchUserArticles, fetchFavoriteArticles)
import Views.Feed exposing (viewFeed)
import Views.Profile exposing (viewFollowButton)


type alias Model =
    { profile : WebData Profile
    , articles : WebData Articles
    , activeFeed : Feed
    }


type Feed
    = Personal
    | Favorite


type Msg
    = ActiveFeed Feed
    | FetchProfileResponse (WebData Profile)
    | FetchArticlesResponse (WebData Articles)


initialModel : Model
initialModel =
    Model RemoteData.NotAsked RemoteData.NotAsked Personal


init : String -> Maybe Session -> ( Model, Cmd Msg )
init username session =
    ( { initialModel | profile = RemoteData.Loading, articles = RemoteData.Loading }
    , Cmd.batch
        [ fetchProfile username session |> Cmd.map FetchProfileResponse
        , fetchUserArticles 0 5 username |> Cmd.map FetchArticlesResponse
        ]
    )


viewProfileInfo : WebData Profile -> Html Msg
viewProfileInfo profileData =
    case profileData of
        RemoteData.Success profile ->
            div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                            [ img [ class "user-img", src profile.image ] []
                            , h4 [] [ text profile.username ]
                            , p []
                                [ text profile.bio ]
                            , viewFollowButton profile
                            ]
                        ]
                    ]
                ]

        _ ->
            text ""


view : Model -> Html Msg
view model =
    div [ class "profile-page" ]
        [ viewProfileInfo model.profile
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    [ div [ class "articles-toggle" ]
                        [ ul [ class "nav nav-pills outline-active" ]
                            [ li [ class "nav-item" ]
                                [ a
                                    [ class
                                        ("nav-link"
                                            ++ (if model.activeFeed == Personal then
                                                    " active"
                                                else
                                                    ""
                                               )
                                        )
                                    , href "javascript:void(0)"
                                    , onClick (ActiveFeed Personal)
                                    ]
                                    [ text "My Articles" ]
                                ]
                            , li [ class "nav-item" ]
                                [ a
                                    [ class
                                        ("nav-link"
                                            ++ (if model.activeFeed == Favorite then
                                                    " active"
                                                else
                                                    ""
                                               )
                                        )
                                    , href "javascript:void(0)"
                                    , onClick (ActiveFeed Favorite)
                                    ]
                                    [ text "Favorited Articles" ]
                                ]
                            ]
                        ]
                    , viewFeed model.articles
                    ]
                ]
            ]
        ]


update : Maybe Session -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case ( msg, model.profile ) of
        ( ActiveFeed feed, RemoteData.Success profile ) ->
            case feed of
                Personal ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchUserArticles 0 5 profile.username |> Cmd.map FetchArticlesResponse
                    )

                Favorite ->
                    ( { model | activeFeed = feed, articles = RemoteData.Loading }
                    , fetchFavoriteArticles 0 5 profile.username |> Cmd.map FetchArticlesResponse
                    )

        ( FetchProfileResponse response, _ ) ->
            ( { model | profile = response }, Cmd.none )

        ( FetchArticlesResponse response, _ ) ->
            ( { model | articles = response }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )
