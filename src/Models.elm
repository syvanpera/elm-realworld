module Models exposing (initialModel, Model, Articles, Article, Author, Tags)

import RemoteData exposing (WebData)


initialModel : Model
initialModel =
    { appName = "Conduit"
    , isLoggedIn = False
    , articles = RemoteData.Loading
    , tags = RemoteData.Loading
    }


type alias Model =
    { appName : String
    , isLoggedIn : Bool
    , articles : WebData Articles
    , tags : WebData Tags
    }


type alias Tags =
    { tags : List String }


type alias Articles =
    { articles : List Article
    , articlesCount : Int
    }


type alias Article =
    { title : String
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
