port module Ports exposing (storeSession, onSessionChange)

import Model exposing (Session)


port storeSession : Session -> Cmd msg


port onSessionChange : (Session -> msg) -> Sub msg
