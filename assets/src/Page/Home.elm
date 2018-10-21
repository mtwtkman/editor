module Page.Home exposing (Model, Msg, fetchArticles, init, update, view)

import Article exposing (Article)
import Browser.Navigation as Nav
import Html exposing (Html, a, div, h1, li, text, ul)
import Http
import Json.Decode as Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Route exposing (href)



-- UPDATE


type Msg
    = FetchArticles (Result Http.Error Articles)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchArticles result ->
            case result of
                Ok articles ->
                    ( { model | articles = articles }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- MODEL


type alias Articles =
    List Article


type alias Model =
    { articles : Articles
    , key : Nav.Key
    }


initModel : Nav.Key -> Model
initModel key =
    { articles = [], key = key }


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( initModel navKey, fetchArticles )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "" ]
        , ul [] (List.map titleView model.articles)
        ]


titleView : Article -> Html Msg
titleView article =
    li []
        [ a [ href (Route.Article article.id) ] [ text article.title ]
        ]



-- HTTP


fetchArticles : Cmd Msg
fetchArticles =
    Http.send FetchArticles (Http.get "http://localhost:55301/articles" decoder)


articleDecoder : Decoder Article
articleDecoder =
    succeed Article
        |> required "id" int
        |> required "title" string
        |> required "body" string
        |> required "published" bool
        |> required "created_at" string
        |> required "updated_at" string


decoder : Decoder Articles
decoder =
    list articleDecoder
