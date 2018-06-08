module Data.Feed exposing (Feed, feedDecoder)

import Data.Article exposing (Article, articleDecoder)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)


type alias Feed =
    { articles : List Article
    , articlesCount : Int
    }


feedDecoder : Decode.Decoder Feed
feedDecoder =
    decode Feed
        |> required "articles" (Decode.list articleDecoder)
        |> required "articlesCount" Decode.int
