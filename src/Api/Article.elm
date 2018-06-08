module Api.Article exposing (fetchArticle, favoriteArticle, fetchComments, fetchTags)

import Http
import RemoteData exposing (WebData)
import Api.Helpers exposing (baseApiUrl)
import Data.Article exposing (Article, Slug, Comments, Tags, articleDecoder, nestedArticleDecoder, commentsDecoder, tagsDecoder)


fetchArticleUrl : String -> String
fetchArticleUrl slug =
    baseApiUrl ++ "articles/" ++ slug


favoriteArticleUrl : String -> String
favoriteArticleUrl slug =
    baseApiUrl ++ "articles/" ++ slug ++ "/favorite"


fetchCommentsUrl : String -> String
fetchCommentsUrl slug =
    baseApiUrl ++ "articles/" ++ slug ++ "/comments"


fetchTagsUrl : String
fetchTagsUrl =
    baseApiUrl ++ "tags"


fetchArticle : Slug -> Cmd (WebData Article)
fetchArticle slug =
    Http.get (fetchArticleUrl slug) nestedArticleDecoder
        |> RemoteData.sendRequest


favoriteArticle : String -> Http.Request Article
favoriteArticle slug =
    Http.post (favoriteArticleUrl slug) Http.emptyBody articleDecoder


fetchComments : Slug -> Cmd (WebData Comments)
fetchComments slug =
    Http.get (fetchCommentsUrl slug) commentsDecoder
        |> RemoteData.sendRequest


fetchTags : Cmd (WebData Tags)
fetchTags =
    Http.get fetchTagsUrl tagsDecoder
        |> RemoteData.sendRequest
