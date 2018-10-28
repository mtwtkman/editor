module Page.Article exposing (Model, Msg, init, update, view)

import Article exposing (Article, articleDecoder)
import Article.Id as Id exposing (Id)
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Http
import Json.Decode exposing (Decoder, list, succeed)
import Json.Decode.Pipeline exposing (required)
import Route exposing (href)
import Tag exposing (Tag, tagDecoder)



-- UDPATE


type Msg
    = FetchArticle (Result Http.Error Data)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchArticle result ->
            case result of
                Ok data ->
                    ( { model | data = Just data }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- MODEL


type alias Data =
    { article : Article
    , tags : List Tag
    }


type alias Model =
    { data : Maybe Data
    , key : Nav.Key
    }


initModel : Nav.Key -> Model
initModel key =
    { data = Nothing, key = key }


init : Nav.Key -> Id -> ( Model, Cmd Msg )
init navKey id =
    ( initModel navKey, fetchArticle id )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ innerView model.data ]
        , a [ href Route.Home ] [ text "back" ]
        ]


innerView : Maybe Data -> Html Msg
innerView maybeData =
    case maybeData of
        Nothing ->
            div [] []

        Just data ->
            div [] [ text data.article.title ]



-- HTTP


fetchArticle : Id -> Cmd Msg
fetchArticle id =
    Http.send FetchArticle (Http.get ("http://localhost:55301/articles/" ++ Id.toString id) decoder)


decoder : Decoder Data
decoder =
    succeed Data
        |> required "article" articleDecoder
        |> required "tags" (list tagDecoder)
