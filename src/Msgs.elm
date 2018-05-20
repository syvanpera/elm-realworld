module Msgs exposing (..)

import RemoteData exposing (WebData)
import Models exposing (Articles, Tags)


type Msg
    = OnFetchArticles (WebData Articles)
    | OnFetchTags (WebData Tags)
