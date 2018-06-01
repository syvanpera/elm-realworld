module Api exposing (fetchArticles, fetchTags, fetchArticle, fetchFeed, authUser)

import Http
import Json.Decode as Decode exposing (at, nullable)
import Json.Decode.Extra
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt)
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra
import HttpBuilder exposing (RequestBuilder, withExpect, withHeader, toRequest)
import RemoteData exposing (WebData)
import Model exposing (Articles, Article, Slug, Author, Tags, Tag, User, Session)


baseApiUrl : String
baseApiUrl =
    "https://conduit.productionready.io/api/"


fetchArticlesUrl : Int -> Maybe Tag -> String
fetchArticlesUrl offset tag =
    let
        tagParam =
            case tag of
                Just value ->
                    "&tag=" ++ value

                Nothing ->
                    ""
    in
        baseApiUrl ++ "articles?limit=10&offset=" ++ (toString offset) ++ tagParam


fetchTagsUrl : String
fetchTagsUrl =
    baseApiUrl ++ "tags"


fetchArticleUrl : String -> String
fetchArticleUrl slug =
    baseApiUrl ++ "articles/" ++ slug


fetchFeedUrl : Int -> String
fetchFeedUrl offset =
    baseApiUrl ++ "articles/feed?limit=10&offset=" ++ (toString offset)


authUrl : String
authUrl =
    baseApiUrl ++ "users/login"


withAuthorization : Maybe Session -> RequestBuilder a -> RequestBuilder a
withAuthorization session builder =
    case session of
        Just session ->
            builder
                |> withHeader "authorization" ("Token " ++ session.token)

        Nothing ->
            builder


fetchArticles : Int -> Maybe Tag -> Cmd (WebData Articles)
fetchArticles offset tag =
    HttpBuilder.get (fetchArticlesUrl offset tag)
        |> withExpect (Http.expectJson articlesDecoder)
        |> toRequest
        |> RemoteData.sendRequest


fetchArticle : Slug -> Cmd (WebData Article)
fetchArticle slug =
    Http.get (fetchArticleUrl slug) articleDecoderWithBody
        |> RemoteData.sendRequest


fetchTags : Cmd (WebData Tags)
fetchTags =
    Http.get fetchTagsUrl tagsDecoder
        |> RemoteData.sendRequest


fetchFeed : Int -> Maybe Session -> Cmd (WebData Articles)
fetchFeed offset session =
    HttpBuilder.get (fetchFeedUrl offset)
        |> withExpect (Http.expectJson articlesDecoder)
        |> withAuthorization session
        |> toRequest
        |> RemoteData.sendRequest


authUser : String -> String -> Http.Request User
authUser email password =
    let
        user =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body =
            Encode.object [ ( "user", user ) ]
                |> Http.jsonBody
    in
        Http.post authUrl body userDecoder



-- JSON Decoders & Encoders


articlesDecoder : Decode.Decoder Articles
articlesDecoder =
    decode Articles
        |> required "articles" (Decode.list articleDecoder)
        |> required "articlesCount" Decode.int


articleDecoderWithBody : Decode.Decoder Article
articleDecoderWithBody =
    decode Article
        |> requiredAt [ "article", "title" ] Decode.string
        |> requiredAt [ "article", "slug" ] Decode.string
        |> requiredAt [ "article", "description" ] Decode.string
        |> requiredAt [ "article", "body" ] Decode.string
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
        |> required "body" Decode.string
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


userDecoder : Decode.Decoder User
userDecoder =
    decode User
        |> requiredAt [ "user", "id" ] Decode.int
        |> requiredAt [ "user", "email" ] Decode.string
        |> requiredAt [ "user", "username" ] Decode.string
        |> requiredAt [ "user", "token" ] Decode.string
        |> requiredAt [ "user", "createdAt" ] Json.Decode.Extra.date
        |> requiredAt [ "user", "updatedAt" ] Json.Decode.Extra.date
        |> requiredAt [ "user", "bio" ] (Decode.nullable Decode.string)
        |> requiredAt [ "user", "image" ] (Decode.nullable Decode.string)


userEncoder : User -> Encode.Value
userEncoder user =
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "token", Encode.string user.token )
        , ( "username", Encode.string user.username )
        , ( "bio", EncodeExtra.maybe Encode.string user.bio )
        , ( "image", EncodeExtra.maybe Encode.string user.image )
        ]
