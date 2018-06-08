module Data.Article exposing (Article, Slug, Body, Comments, Comment, Tags, Tag, articleDecoder, nestedArticleDecoder, commentsDecoder, commentDecoder, tagsDecoder)

import Json.Decode as Decode exposing (at)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Json.Decode.Extra
import Date exposing (Date)
import Data.Profile exposing (Profile, profileDecoder)


type alias Article =
    { title : String
    , slug : Slug
    , description : String
    , body : Body
    , createdAt : Date
    , updatedAt : Date
    , tagList : List Tag
    , author : Profile
    , favoritesCount : Int
    }


type alias Slug =
    String


type alias Body =
    String


type alias Comment =
    { id : Int
    , createdAt : Date
    , updatedAt : Date
    , body : String
    , author : Profile
    }


type alias Comments =
    { comments : List Comment }


type alias Tag =
    String


type alias Tags =
    { tags : List Tag }


nestedArticleDecoder : Decode.Decoder Article
nestedArticleDecoder =
    at [ "article" ] articleDecoder


articleDecoder : Decode.Decoder Article
articleDecoder =
    decode Article
        |> required "title" Decode.string
        |> required "slug" Decode.string
        |> required "description" Decode.string
        |> required "body" Decode.string
        |> required "createdAt" Json.Decode.Extra.date
        |> required "updatedAt" Json.Decode.Extra.date
        |> required "tagList" (Decode.list Decode.string)
        |> required "author" profileDecoder
        |> required "favoritesCount" Decode.int


commentsDecoder : Decode.Decoder Comments
commentsDecoder =
    decode Comments
        |> required "comments" (Decode.list commentDecoder)


commentDecoder : Decode.Decoder Comment
commentDecoder =
    decode Comment
        |> required "id" Decode.int
        |> required "createdAt" Json.Decode.Extra.date
        |> required "updatedAt" Json.Decode.Extra.date
        |> required "body" Decode.string
        |> required "author" profileDecoder


tagsDecoder : Decode.Decoder Tags
tagsDecoder =
    decode Tags
        |> required "tags" (Decode.list Decode.string)
