module Api.Feed exposing (fetchFeed, fetchUserFeed, fetchFavoriteFeed, fetchPrivateFeed)

import Http
import HttpBuilder exposing (withExpect, toRequest)
import RemoteData exposing (WebData)
import Api.Helpers exposing (baseApiUrl, withAuthorization)
import Data.Feed exposing (Feed, feedDecoder)
import Data.Article exposing (Tag)
import Data.Session exposing (Session)


fetchFeedUrl : Int -> Int -> Maybe Tag -> String
fetchFeedUrl offset limit tag =
    let
        tagParam =
            case tag of
                Just value ->
                    "&tag=" ++ value

                Nothing ->
                    ""
    in
        baseApiUrl ++ "articles?limit=" ++ toString limit ++ "&offset=" ++ toString offset ++ tagParam


fetchUserFeedUrl : Int -> Int -> String -> String
fetchUserFeedUrl offset limit username =
    baseApiUrl ++ "articles?limit=" ++ toString limit ++ "&offset=" ++ toString offset ++ "&author=" ++ username


fetchFavoriteFeedUrl : Int -> Int -> String -> String
fetchFavoriteFeedUrl offset limit username =
    baseApiUrl ++ "articles?limit=" ++ toString limit ++ "&offset=" ++ toString offset ++ "&favorited=" ++ username


fetchPrivateFeedUrl : Int -> Int -> String
fetchPrivateFeedUrl offset limit =
    baseApiUrl ++ "articles/feed?limit=" ++ toString limit ++ "&offset=" ++ toString offset


fetchFeed : Int -> Int -> Maybe Tag -> Cmd (WebData Feed)
fetchFeed offset limit tag =
    HttpBuilder.get (fetchFeedUrl offset limit tag)
        |> withExpect (Http.expectJson feedDecoder)
        |> toRequest
        |> RemoteData.sendRequest


fetchUserFeed : Int -> Int -> String -> Cmd (WebData Feed)
fetchUserFeed offset limit username =
    HttpBuilder.get (fetchUserFeedUrl offset limit username)
        |> withExpect (Http.expectJson feedDecoder)
        |> toRequest
        |> RemoteData.sendRequest


fetchFavoriteFeed : Int -> Int -> String -> Cmd (WebData Feed)
fetchFavoriteFeed offset limit username =
    HttpBuilder.get (fetchFavoriteFeedUrl offset limit username)
        |> withExpect (Http.expectJson feedDecoder)
        |> toRequest
        |> RemoteData.sendRequest


fetchPrivateFeed : Int -> Int -> Maybe Session -> Cmd (WebData Feed)
fetchPrivateFeed offset limit session =
    HttpBuilder.get (fetchPrivateFeedUrl offset limit)
        |> withExpect (Http.expectJson feedDecoder)
        |> withAuthorization session
        |> toRequest
        |> RemoteData.sendRequest
