module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)



-- UPDATE


type Msg
    = FetchArticles (Result Http.Error Model)


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        FetchArticles result ->
            case result of
                Ok articles ->
                    ( articles, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- MODEL


type alias Article =
    { id : Int
    , title : String
    , body : String
    , published : Bool
    , created_at : String
    , updated_at : String
    }


type alias Model =
    List Article


initModel : Model
initModel =
    []


init : () -> ( Model, Cmd Msg )
init _ =
    ( initModel, fetchArticles )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Articles" ]
        , ul [] (List.map titleView model)
        ]


titleView : Article -> Html Msg
titleView article =
    li [] [ text article.title ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



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


decoder : Decoder Model
decoder =
    list articleDecoder
