module Page.Article exposing (Model, Msg, init, update, view)

import Article exposing (Article, articleDecoder, empty)
import Article.Id as Id exposing (Id)
import Browser.Navigation as Nav
import Bulma.Columns as Columns
import Bulma.Elements as Elements
import Bulma.Form as Form
import Html exposing (Attribute, Html, a, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode exposing (Decoder, list, succeed)
import Json.Decode.Pipeline exposing (required)
import Markdown exposing (toHtml)
import Route exposing (href)
import Tag as Tag exposing (Tag, tagDecoder)



-- UDPATE


type Msg
    = FetchArticle (Result Http.Error Data)
    | UpdateTitle String
    | UpdateTags String
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

        UpdateTags tags ->
            let
                newData =
                    Maybe.map
                        (\d ->
                            let
                                new =
                                    List.map (\t -> { id = 0, name = t }) (String.split " " <| String.trim tags)
                            in
                            { d | tags = new }
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
        [ Columns.columns
            Columns.columnsModifiers
            []
            [ Columns.column
                Columns.columnModifiers
                []
                [ titleView article.title
                ]
            ]
        , Columns.columns
            Columns.columnsModifiers
            []
            [ Columns.column
                Columns.columnModifiers
                []
                [ tagsView tags
                ]
            ]
        , Columns.columns
            Columns.columnsModifiers
            []
            (List.map
                (\v -> Columns.column Columns.columnModifiers [] [ v article.body ])
                [ editorView, previewView ]
            )
        , Columns.columns
            Columns.columnsModifiers
            []
            [ backToHome
            ]
        ]


titleView : String -> Html Msg
titleView title =
    let
        controlAttrs =
            []

        inputAttrs =
            [ Events.onInput UpdateTitle
            , Attributes.value title
            ]
    in
    Form.field []
        [ Form.controlText
            Form.controlInputModifiers
            controlAttrs
            inputAttrs
            []
        ]


tagsView : List Tag -> Html Msg
tagsView tags =
    let
        controlAttrs =
            []

        inputAttrs =
            [ Events.onInput UpdateTags
            , Attributes.value <| String.join " " (List.map Tag.toString tags)
            ]
    in
    Form.field []
        [ Form.controlText
            Form.controlInputModifiers
            controlAttrs
            inputAttrs
            []
        ]


fullHeight : Attribute msg
fullHeight =
    Attributes.style "height" "100%"


fullMaxHeight : Attribute msg
fullMaxHeight =
    Attributes.style "max-height" "100%"


editorView : String -> Html Msg
editorView body =
    let
        controlAttrs =
            [ fullHeight
            , fullMaxHeight
            ]

        inputAttrs =
            [ Events.onInput UpdateBody
            , Attributes.value body
            , fullHeight
            , fullMaxHeight
            ]
    in
    Form.field [ fullHeight, fullMaxHeight ]
        [ Form.controlTextArea
            Form.controlTextAreaModifiers
            controlAttrs
            inputAttrs
            []
        ]


previewView : String -> Html Msg
previewView body =
    toHtml [] body


backToHome : Html Msg
backToHome =
    Elements.button
        Elements.buttonModifiers
        [ href Route.Home ]
        [ text "back to Home" ]



-- HTTP


fetchArticle : Id -> Cmd Msg
fetchArticle id =
    Http.send FetchArticle (Http.get ("http://localhost:55301/articles/" ++ Id.toString id) decoder)


decoder : Decoder Data
decoder =
    succeed Data
        |> required "article" articleDecoder
        |> required "tags" (list tagDecoder)
