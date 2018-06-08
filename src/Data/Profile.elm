module Data.Profile exposing (Profile, profileDecoder, nestedProfileDecoder)

import Json.Decode as Decode exposing (at)
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt, optionalAt)


type alias Profile =
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


nestedProfileDecoder : Decode.Decoder Profile
nestedProfileDecoder =
    at [ "profile" ] profileDecoder


profileDecoder : Decode.Decoder Profile
profileDecoder =
    decode Profile
        |> required "username" Decode.string
        |> optional "bio" Decode.string ""
        |> required "image" Decode.string
        |> required "following" Decode.bool
