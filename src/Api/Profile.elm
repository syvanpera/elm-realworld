module Api.Profile exposing (fetchProfile)

import Http
import RemoteData exposing (WebData)
import HttpBuilder exposing (withExpect, toRequest)
import Api.Helpers exposing (baseApiUrl, withAuthorization)
import Data.Profile exposing (Profile, nestedProfileDecoder)
import Data.Session exposing (Session)


fetchProfileUrl : String -> String
fetchProfileUrl username =
    baseApiUrl ++ "profiles/" ++ username


fetchProfile : String -> Maybe Session -> Cmd (WebData Profile)
fetchProfile username session =
    HttpBuilder.get (fetchProfileUrl username)
        |> withExpect (Http.expectJson nestedProfileDecoder)
        |> withAuthorization session
        |> toRequest
        |> RemoteData.sendRequest
