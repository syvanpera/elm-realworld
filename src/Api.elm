module Api exposing (fetchArticles, fetchTags, fetchArticle)

import Http
import Json.Decode as Decode exposing (at)
import Json.Decode.Extra
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt)
import RemoteData exposing (WebData)
import Model exposing (Articles, Article, Slug, Author, Tags)


baseApiUrl : String
baseApiUrl =
    "https://conduit.productionready.io/api/"


fetchArticlesUrl : String
fetchArticlesUrl =
    baseApiUrl ++ "articles?limit=10"


fetchTagsUrl : String
fetchTagsUrl =
    baseApiUrl ++ "tags"


fetchArticleUrl : String -> String
fetchArticleUrl slug =
    baseApiUrl ++ "articles/" ++ slug


fetchArticles : Cmd (WebData Articles)
fetchArticles =
    Http.get fetchArticlesUrl articlesDecoder
        |> RemoteData.sendRequest


fetchArticle : Slug -> Cmd (WebData Article)
fetchArticle slug =
    Http.get (fetchArticleUrl slug) nestedArticleDecoder
        |> RemoteData.sendRequest


fetchTags : Cmd (WebData Tags)
fetchTags =
    Http.get fetchTagsUrl tagsDecoder
        |> RemoteData.sendRequest


articlesDecoder : Decode.Decoder Articles
articlesDecoder =
    decode Articles
        |> required "articles" (Decode.list articleDecoder)
        |> required "articlesCount" Decode.int


nestedArticleDecoder : Decode.Decoder Article
nestedArticleDecoder =
    decode Article
        |> requiredAt [ "article", "title" ] Decode.string
        |> requiredAt [ "article", "slug" ] Decode.string
        |> requiredAt [ "article", "description" ] Decode.string
        |> requiredAt [ "article", "createdAt" ] Json.Decode.Extra.date
        |> requiredAt [ "article", "updatedAt" ] Json.Decode.Extra.date
        |> requiredAt [ "article", "tagList" ] (Decode.list Decode.string)
        |> requiredAt [ "article", "author" ] authorDecoder
        |> requiredAt [ "article", "favoritesCount" ] Decode.int


articleDecoder : Decode.Decoder Article
articleDecoder =
    decode Article
        |> required "title" Decode.string
        |> required "slug" Decode.string
        |> required "description" Decode.string
        |> required "createdAt" Json.Decode.Extra.date
        |> required "updatedAt" Json.Decode.Extra.date
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
