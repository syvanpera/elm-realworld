module Util exposing (formatDate)

import Date exposing (Date)
import Date.Format


formatDate : Date -> String
formatDate date =
    Date.Format.format "%B %e, %Y" date
