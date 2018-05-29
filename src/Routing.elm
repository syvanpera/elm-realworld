module Routing exposing (Route(..), parseLocation)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = Home
    | Login
    | Register
    | NotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Home top
        , map Login (s "login")
        , map Register (s "register")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFound
