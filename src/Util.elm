module Util exposing (toggleText, formatDate, validSession)

import Date exposing (Date)
import Date.Format
import Data.Session exposing (Session)


toggleText : Bool -> String -> String -> String
toggleText cond trueText falseText =
    if cond then
        trueText
    else
        falseText


formatDate : Date -> String
formatDate date =
    Date.Format.format "%B %e, %Y" date


validSession : Maybe Session -> Bool
validSession session =
    case session of
        Just _ ->
            True

        Nothing ->
            False
