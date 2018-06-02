module Routing exposing (Route(..), parseLocation)

import Model exposing (Slug)
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = Home
    | Article Slug
    | Profile String
    | Login
    | Register
    | NotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Home top
        , map Login (s "login")
        , map Register (s "register")
        , map Article (s "article" </> string)
        , map Profile (s "profile" </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFound
