module Page.Article exposing (Model, Msg, init, update, view)

import Article exposing (Article, articleDecoder, empty)
import Article.Id as Id exposing (Id)
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Http
import Json.Decode exposing (Decoder, list, succeed)
import Json.Decode.Pipeline exposing (required)
import Markdown exposing (toHtml)
import Route exposing (href)
import Tag exposing (Tag, tagDecoder)



-- UDPATE


type Msg
    = FetchArticle (Result Http.Error Data)
    | UpdateTitle String
    | UpdateBody String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchArticle result ->
            case result of
                Ok data ->
                    ( { model | data = Just data }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        UpdateTitle title ->
            let
                newData =
                    Maybe.map
                        (\d ->
                            let
                                old =
                                    d.article

                                new =
                                    { old | title = title }
                            in
                            { d | article = new }
                        )
                        model.data
            in
            ( { model | data = newData }, Cmd.none )

        UpdateBody body ->
            let
                newData =
                    Maybe.map
                        (\d ->
                            let
                                old =
                                    d.article

                                new =
                                    { old | body = body }
                            in
                            { d | article = new }
                        )
                        model.data
            in
            ( { model | data = newData }, Cmd.none )



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


emptyData : Data
emptyData =
    { article = empty
    , tags = []
    }



-- VIEW


view : Model -> Html Msg
view model =
    let
        { article, tags } =
            case model.data of
                Nothing ->
                    emptyData

                Just data ->
                    data
    in
    div []
        [ Grid.row []
            [ Grid.col []
                [ titleView article.title
                , tagsView tags
                , Grid.row []
                    [ Grid.col []
                        [ editorView article.body
                        , previewView article.body
                        ]
                    ]
                , a [ href Route.Home ] [ text "back" ]
                ]
            ]
        ]


titleView : String -> Html Msg
titleView title =
    Input.text
        [ Input.onInput UpdateTitle
        , Input.value title
        ]


tagsView : List Tag -> Html Msg
tagsView tags =
    Grid.row [] <|
        List.map
            tagView
            tags


tagView : Tag -> Grid.Column Msg
tagView tag =
    Grid.col [] <| [ text tag.name ]


editorView : String -> Html Msg
editorView body =
    Textarea.textarea
        [ Textarea.onInput UpdateBody
        , Textarea.value body
        ]


previewView : String -> Html Msg
previewView body =
    toHtml [] body



-- HTTP


fetchArticle : Id -> Cmd Msg
fetchArticle id =
    Http.send FetchArticle (Http.get ("http://localhost:55301/articles/" ++ Id.toString id) decoder)


decoder : Decoder Data
decoder =
    succeed Data
        |> required "article" articleDecoder
        |> required "tags" (list tagDecoder)
