module Page.Article exposing (Model, Msg, init, update, view)

import Article exposing (Article, articleDecoder, empty)
import Article.Id as Id exposing (Id)
import Browser.Navigation as Nav
import Bulma.Columns as Columns
import Bulma.Elements as Elements exposing (buttonModifiers)
import Bulma.Form as Form
import Bulma.Modifiers as Modifiers
import Const exposing (article_endpoint)
import Html exposing (Attribute, Html, a, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Http as Http exposing (Body, Request, expectStringResponse, jsonBody)
import Json.Decode exposing (Decoder, list, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (bool, int, object, string)
import Markdown exposing (toHtml)
import Route exposing (href)
import Tag as Tag exposing (Tag, tagDecoder)
import Url.Builder exposing (absolute)



-- UDPATE


type Msg
    = FetchArticle (Result Http.Error Data)
    | UpdateTitle String
    | UpdateTags String
    | UpdateBody String
    | RequestUpdateArticle
    | UpdateArticle (Result Http.Error ())


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

        RequestUpdateArticle ->
            ( model, updateArticle model )

        UpdateArticle result ->
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
            [ Modifiers.pulledRight ]
            [ Elements.buttons Modifiers.Right
                []
                [ updateButton
                , backToHome
                ]
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
    a
        [ href Route.Home
        , Attributes.class "button"
        ]
        [ text "back to Home" ]


updateButton : Html Msg
updateButton =
    Elements.button
        { buttonModifiers | color = Modifiers.Primary }
        [ Events.onClick RequestUpdateArticle ]
        [ text "update" ]



-- HTTP


toUrl : Id -> String
toUrl id =
    String.join "/" [ article_endpoint, Id.toString id ]


fetchArticle : Id -> Cmd Msg
fetchArticle id =
    Http.send FetchArticle (Http.get (toUrl id) decoder)


put : String -> Body -> Request ()
put url body =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , expect = expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }


updateArticle : Model -> Cmd Msg
updateArticle model =
    case model.data of
        Just data ->
            let
                body =
                    jsonBody <| encoder data
            in
            Http.send UpdateArticle (put (toUrl data.article.id) body)

        Nothing ->
            Cmd.none


decoder : Decoder Data
decoder =
    succeed Data
        |> required "article" articleDecoder
        |> required "tags" (list tagDecoder)


encoder : Data -> Encode.Value
encoder data =
    let
        article =
            object
                [ ( "id", Id.encoder data.article.id )
                , ( "title", string data.article.title )
                , ( "body", string data.article.body )
                , ( "published", bool data.article.published )
                , ( "created_at", string data.article.created_at )
                , ( "updated_at", string data.article.updated_at )
                ]

        tag_ids =
            Encode.list
                (\t ->
                    int t.id
                )
                data.tags
    in
    object
        [ ( "article", article )
        , ( "tag_ids", tag_ids )
        ]
