module Model exposing (..)


type alias Session =
    { username : String
    }


type alias Tags =
    { tags : List String }


type alias ArticleSlug =
    String


type alias Author =
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


type alias Article =
    { title : String
    , slug : ArticleSlug
    , description : String
    , createdAt : String
    , tagList : List String
    , author : Author
    , favoritesCount : Int
    }


type alias Articles =
    { articles : List Article
    , articlesCount : Int
    }
