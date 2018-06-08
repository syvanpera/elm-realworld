module Api.Helpers exposing (baseApiUrl, withAuthorization)

import Data.Session exposing (Session)
import HttpBuilder exposing (RequestBuilder, withHeader)


baseApiUrl : String
baseApiUrl =
    "https://conduit.productionready.io/api/"


withAuthorization : Maybe Session -> RequestBuilder a -> RequestBuilder a
withAuthorization maybeSession builder =
    case maybeSession of
        Just session ->
            builder
                |> withHeader "authorization" ("Token " ++ session.token)

        Nothing ->
            builder
