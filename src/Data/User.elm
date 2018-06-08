module Data.User exposing (User, userDecoder)

import Date exposing (Date)
import Json.Decode as Decode
import Json.Decode.Extra
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt, optionalAt)


type alias User =
    { id : Int
    , email : String
    , username : String
    , token : String
    , createdAt : Date
    , updatedAt : Date
    , bio : Maybe String
    , image : Maybe String
    }


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
