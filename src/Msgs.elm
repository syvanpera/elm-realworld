module Msgs exposing (..)

import RemoteData exposing (WebData)
import Navigation exposing (Location)
import Models exposing (Articles, Article, Tags)


type Msg
    = OnFetchArticles (WebData Articles)
    | OnFetchArticle (WebData Article)
    | OnFetchTags (WebData Tags)
    | OnLocationChange Location
