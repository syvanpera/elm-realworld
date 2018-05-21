module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { appName : String
    , isLoggedIn : Bool
    , article : WebData Article
    , articles : WebData Articles
    , tags : WebData Tags
    , route : Route
    }


initialModel : Route -> Model
initialModel route =
    { appName = "Conduit"
    , isLoggedIn = False
    , article = RemoteData.NotAsked
    , articles = RemoteData.Loading
    , tags = RemoteData.Loading
    , route = route
    }


type alias Tags =
    { tags : List String }


type alias Articles =
    { articles : List Article
    , articlesCount : Int
    }


type alias ArticleSlug =
    String


type alias Article =
    { title : String
    , slug : ArticleSlug
    , description : String
    , createdAt : String
    , tagList : List String
    , author : Author
    , favoritesCount : Int
    }


type alias Author =
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


type Route
    = HomeRoute
    | ArticleRoute ArticleSlug
    | NotFoundRoute
