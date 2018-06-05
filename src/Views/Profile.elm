module Views.Profile exposing (viewFollowButton)

import Html exposing (Html, text, button, i)
import Html.Attributes exposing (class)
import Model exposing (Profile)


viewFollowButton : Profile -> Html msg
viewFollowButton profile =
    button
        [ class "btn btn-sm btn-outline-secondary action-btn" ]
        [ i [ class "ion-plus-round" ] []
        , text
            ((if profile.following then
                " Unfollow "
              else
                " Follow "
             )
                ++ profile.username
            )
        ]
