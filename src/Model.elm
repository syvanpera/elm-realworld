module Model exposing (..)

import Date exposing (Date)


type alias Session =
    { username : String
    }


type alias Tag =
    String


type alias Tags =
    { tags : List Tag }


type alias Slug =
    String


type alias Author =
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


type alias Article =
    { title : String
    , slug : Slug
    , description : String
    , createdAt : Date
    , updatedAt : Date
    , tagList : List Tag
    , author : Author
    , favoritesCount : Int
    }


type alias Articles =
    { articles : List Article
    , articlesCount : Int
    }
