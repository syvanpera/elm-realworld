module Api exposing (fetchArticles, fetchTags)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import RemoteData exposing (WebData)
import Model exposing (Articles, Article, ArticleSlug, Author, Tags)


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


fetchArticle : ArticleSlug -> Cmd (WebData Article)
fetchArticle slug =
    Http.get (fetchArticleUrl slug) articleDecoder
        |> RemoteData.sendRequest


fetchTags : Cmd (WebData Tags)
fetchTags =
    Http.get fetchTagsUrl tagsDecoder
        |> RemoteData.sendRequest


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
        |> required "slug" Decode.string
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
