module Page.Profile exposing (Model, Msg, initialModel, view, update)

import Html exposing (Html, div, text, p, img, h1, h4, button, ul, li, a, i, span)
import Html.Attributes exposing (class, src, href)


type alias Model =
    { foo : String
    }


type Msg
    = NoOp


initialModel : Model
initialModel =
    Model ""


view : Model -> Html Msg
view model =
    div [ class "profile-page" ]
        [ div [ class "user-info" ]
            [ div [ class "container" ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                        [ img [ class "user-img", src "http://i.imgur.com/Qr71crq.jpg" ] []
                        , h4 [] [ text "Eric Simons" ]
                        , p []
                            [ text "Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games          " ]
                        , button [ class "btn btn-sm btn-outline-secondary action-btn" ]
                            [ i [ class "ion-plus-round" ] []
                            , text " Follow Eric Simons"
                            ]
                        ]
                    ]
                ]
            ]
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    [ div [ class "articles-toggle" ]
                        [ ul [ class "nav nav-pills outline-active" ]
                            [ li [ class "nav-item" ]
                                [ a [ class "nav-link active", href "" ] [ text "My Articles" ] ]
                            , li [ class "nav-item" ]
                                [ a [ class "nav-link", href "" ] [ text "Favorited Articles" ] ]
                            ]
                        ]
                    , div [ class "article-preview" ]
                        [ div [ class "article-meta" ]
                            [ a [ href "" ] [ img [ src "http://i.imgur.com/Qr71crq.jpg" ] [] ]
                            , div [ class "info" ]
                                [ a [ class "author", href "" ] [ text "Eric Simons" ]
                                , span [ class "date" ] [ text "January 20th" ]
                                ]
                            , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                                [ i [ class "ion-heart" ] []
                                , text "29"
                                ]
                            ]
                        , a [ class "preview-link", href "" ]
                            [ h1 [] [ text "How to build webapps that scale" ]
                            , p [] [ text "This is the description for the post." ]
                            , span [] [ text "Read more..." ]
                            ]
                        ]
                    , div [ class "article-preview" ]
                        [ div [ class "article-meta" ]
                            [ a [ href "" ] [ img [ src "http://i.imgur.com/N4VcUeJ.jpg" ] [] ]
                            , div [ class "info" ]
                                [ a [ class "author", href "" ] [ text "Albert Pai" ]
                                , span [ class "date" ] [ text "January 20th" ]
                                ]
                            , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                                [ i [ class "ion-heart" ] []
                                , text "32"
                                ]
                            ]
                        , a [ class "preview-link", href "" ]
                            [ h1 []
                                [ text "The song you won't ever stop singing. No matter how hard you try." ]
                            , p [] [ text "This is the description for the post." ]
                            , span [] [ text "Read more..." ]
                            , ul [ class "tag-list" ]
                                [ li [ class "tag-default tag-pill tag-outline" ]
                                    [ text "Music" ]
                                , li [ class "tag-default tag-pill tag-outline" ]
                                    [ text "Song" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
