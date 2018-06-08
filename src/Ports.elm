port module Ports exposing (storeSession, onSessionChange)

import Data.Session exposing (Session)


port storeSession : Session -> Cmd msg


port onSessionChange : (Session -> msg) -> Sub msg
