module Api exposing (fetchArticles, fetchUserArticles, fetchFavoriteArticles, fetchTags, fetchArticle, fetchComments, fetchFeed, fetchProfile, loginUser, registerUser)

import Http
import Json.Decode as Decode exposing (at, nullable)
import Json.Decode.Extra
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt, optionalAt)
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra
import HttpBuilder exposing (RequestBuilder, withExpect, withHeader, toRequest)
import RemoteData exposing (WebData)
import Model exposing (Articles, Article, Comments, Comment, Slug, Profile, Tags, Tag, User, Session)


baseApiUrl : String
baseApiUrl =
    "https://conduit.productionready.io/api/"


fetchArticlesUrl : Int -> Int -> Maybe Tag -> String
fetchArticlesUrl offset limit tag =
    let
        tagParam =
            case tag of
                Just value ->
                    "&tag=" ++ value

                Nothing ->
                    ""
    in
        baseApiUrl ++ "articles?limit=" ++ (toString limit) ++ "&offset=" ++ (toString offset) ++ tagParam


fetchUserArticlesUrl : Int -> Int -> String -> String
fetchUserArticlesUrl offset limit username =
    baseApiUrl ++ "articles?limit=" ++ (toString limit) ++ "&offset=" ++ (toString offset) ++ "&author=" ++ username


fetchFavoriteArticlesUrl : Int -> Int -> String -> String
fetchFavoriteArticlesUrl offset limit username =
    baseApiUrl ++ "articles?limit=" ++ (toString limit) ++ "&offset=" ++ (toString offset) ++ "&favorited=" ++ username


fetchTagsUrl : String
fetchTagsUrl =
    baseApiUrl ++ "tags"


fetchArticleUrl : String -> String
fetchArticleUrl slug =
    baseApiUrl ++ "articles/" ++ slug


fetchCommentsUrl : String -> String
fetchCommentsUrl slug =
    baseApiUrl ++ "articles/" ++ slug ++ "/comments"


fetchFeedUrl : Int -> String
fetchFeedUrl offset =
    baseApiUrl ++ "articles/feed?limit=10&offset=" ++ (toString offset)


fetchProfileUrl : String -> String
fetchProfileUrl username =
    baseApiUrl ++ "profiles/" ++ username


registerUrl : String
registerUrl =
    baseApiUrl ++ "users"


loginUrl : String
loginUrl =
    baseApiUrl ++ "users/login"


withAuthorization : Maybe Session -> RequestBuilder a -> RequestBuilder a
withAuthorization session builder =
    case session of
        Just session ->
            builder
                |> withHeader "authorization" ("Token " ++ session.token)

        Nothing ->
            builder


fetchArticles : Int -> Int -> Maybe Tag -> Cmd (WebData Articles)
fetchArticles offset limit tag =
    HttpBuilder.get (fetchArticlesUrl offset limit tag)
        |> withExpect (Http.expectJson articlesDecoder)
        |> toRequest
        |> RemoteData.sendRequest


fetchUserArticles : Int -> Int -> String -> Cmd (WebData Articles)
fetchUserArticles offset limit username =
    HttpBuilder.get (fetchUserArticlesUrl offset limit username)
        |> withExpect (Http.expectJson articlesDecoder)
        |> toRequest
        |> RemoteData.sendRequest


fetchFavoriteArticles : Int -> Int -> String -> Cmd (WebData Articles)
fetchFavoriteArticles offset limit username =
    HttpBuilder.get (fetchFavoriteArticlesUrl offset limit username)
        |> withExpect (Http.expectJson articlesDecoder)
        |> toRequest
        |> RemoteData.sendRequest


fetchArticle : Slug -> Cmd (WebData Article)
fetchArticle slug =
    Http.get (fetchArticleUrl slug) articleDecoderWithBody
        |> RemoteData.sendRequest


fetchComments : Slug -> Cmd (WebData Comments)
fetchComments slug =
    Http.get (fetchCommentsUrl slug) commentsDecoder
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


fetchProfile : String -> Cmd (WebData Profile)
fetchProfile username =
    Http.get (fetchProfileUrl username) nestedProfileDecoder
        |> RemoteData.sendRequest


loginUser : String -> String -> Http.Request User
loginUser email password =
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
        Http.post loginUrl body userDecoder


registerUser : String -> String -> String -> Http.Request User
registerUser username email password =
    let
        user =
            Encode.object
                [ ( "username", Encode.string username )
                , ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body =
            Encode.object [ ( "user", user ) ]
                |> Http.jsonBody
    in
        Http.post registerUrl body userDecoder



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
        |> requiredAt [ "article", "author" ] profileDecoder
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


nestedProfileDecoder : Decode.Decoder Profile
nestedProfileDecoder =
    decode Profile
        |> requiredAt [ "profile", "username" ] Decode.string
        |> optionalAt [ "profile", "bio" ] Decode.string ""
        |> requiredAt [ "profile", "image" ] Decode.string
        |> requiredAt [ "profile", "following" ] Decode.bool


profileDecoder : Decode.Decoder Profile
profileDecoder =
    decode Profile
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
