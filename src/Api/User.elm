module Api.User exposing (loginUser, registerUser, followUser)

import Http
import Json.Encode as Encode
import Api.Helpers exposing (baseApiUrl, withAuthorization)
import Data.User exposing (User, userDecoder)


followUserUrl : String -> String
followUserUrl username =
    baseApiUrl ++ "profiles/" ++ username ++ "/follow"


registerUrl : String
registerUrl =
    baseApiUrl ++ "users"


loginUrl : String
loginUrl =
    baseApiUrl ++ "users/login"


followUser : String -> Http.Request User
followUser username =
    Http.post (followUserUrl username) Http.emptyBody userDecoder


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
