module Commands exposing (fetchArticles, fetchTags)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import RemoteData
import Msgs exposing (Msg)
import Models exposing (Articles, Article, Author, Tags)


baseApiUrl : String
baseApiUrl =
    "https://conduit.productionready.io/api/"


fetchArticlesUrl : String
fetchArticlesUrl =
    baseApiUrl ++ "articles?limit=10"


fetchTagsUrl : String
fetchTagsUrl =
    baseApiUrl ++ "tags"


fetchArticles : Cmd Msg
fetchArticles =
    Http.get fetchArticlesUrl articlesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchArticles


fetchTags : Cmd Msg
fetchTags =
    Http.get fetchTagsUrl tagsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchTags


articlesDecoder : Decode.Decoder Articles
articlesDecoder =
    decode Articles
        |> required "articles" articleListDecoder
        |> required "articlesCount" Decode.int


articleListDecoder : Decode.Decoder (List Article)
articleListDecoder =
    Decode.list articleDecoder


articleDecoder : Decode.Decoder Article
articleDecoder =
    decode Article
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> required "createdAt" Decode.string
        |> required "tagList" (Decode.list Decode.string)
        |> required "author" authorDecoder
        |> required "favoritesCount" Decode.int


authorDecoder : Decode.Decoder Author
authorDecoder =
    decode Author
        |> required "username" Decode.string
        |> optional "bio" Decode.string ""
        |> required "image" Decode.string
        |> required "following" Decode.bool


tagsDecoder : Decode.Decoder Tags
tagsDecoder =
    decode Tags
        |> required "tags" (Decode.list Decode.string)
