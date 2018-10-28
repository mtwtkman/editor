module Page.Article exposing (Model, Msg, init, update, view)

import Article exposing (Article, articleDecoder)
import Article.Id as Id exposing (Id)
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Http
import Json.Decode exposing (Decoder)
import Route exposing (href)



-- UDPATE


type Msg
    = FetchArticle (Result Http.Error Article)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchArticle result ->
            case result of
                Ok article ->
                    ( { model | article = Just article }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- MODEL


type alias Model =
    { article : Maybe Article
    , key : Nav.Key
    }


initModel : Nav.Key -> Model
initModel key =
    { article = Nothing, key = key }


init : Nav.Key -> Id -> ( Model, Cmd Msg )
init navKey id =
    ( initModel navKey, fetchArticle id )



-- VIEW


view : Model -> Html Msg
view model =
    case model.article of
        Nothing ->
            div []
                [ div []
                    [ text "fetching..."
                    , a [ href Route.Home ] [ text "back" ]
                    ]
                ]

        Just article ->
            div []
                [ text article.title
                ]



-- HTTP


fetchArticle : Id -> Cmd Msg
fetchArticle id =
    Http.send FetchArticle (Http.get ("http://localhost:55301/articles/" ++ Id.toString id) articleDecoder)
