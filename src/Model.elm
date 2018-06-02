module Model exposing (..)

import Date exposing (Date)


type alias Session =
    { username : String
    , token : String
    }


type alias Body =
    String


type alias Tag =
    String


type alias Tags =
    { tags : List Tag }


type alias Slug =
    String


type alias Profile =
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


type alias Article =
    { title : String
    , slug : Slug
    , description : String
    , body : Body
    , createdAt : Date
    , updatedAt : Date
    , tagList : List Tag
    , author : Profile
    , favoritesCount : Int
    }


type alias Articles =
    { articles : List Article
    , articlesCount : Int
    }


type alias Comment =
    { id : Int
    , createdAt : Date
    , updatedAt : Date
    , body : String
    , author : Profile
    }


type alias Comments =
    { comments : List Comment
    }


type alias User =
    { id : Int
    , email : String
    , username : String
    , token : String
    , createdAt : Date
    , updatedAt : Date
    , bio : Maybe String
    , image : Maybe String
    }
