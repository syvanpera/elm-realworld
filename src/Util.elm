module Util exposing (formatDate, isLoggedIn)

import Date exposing (Date)
import Date.Format
import Model exposing (Session)


formatDate : Date -> String
formatDate date =
    Date.Format.format "%B %e, %Y" date


isLoggedIn : Maybe Session -> Bool
isLoggedIn session =
    case session of
        Just _ ->
            True

        Nothing ->
            False
