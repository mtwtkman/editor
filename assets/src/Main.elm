module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (div, h1, text)
import Page.Article as Article
import Page.Home as Home
import Route exposing (Route, fromUrl)
import Url exposing (Url)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }



-- MODEL


type Model
    = Home Home.Model
    | Article Article.Model
    | NotFound Nav.Key


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    changeRouteTo (Route.fromUrl url) navKey



-- UPDATE


type Msg
    = ClickedLink UrlRequest
    | ChangedUrl Url
    | GotHomeMsg Home.Msg
    | GotArticleMsg Article.Msg


changeRouteTo : Maybe Route -> Nav.Key -> ( Model, Cmd Msg )
changeRouteTo maybeRoute navKey =
    case maybeRoute of
        Nothing ->
            ( NotFound navKey, Cmd.none )

        Just Route.Home ->
            Home.init navKey
                |> updateWith Home GotHomeMsg

        Just (Route.Article id) ->
            Article.init navKey id
                |> updateWith Article GotArticleMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( _, NotFound _ ) ->
            ( model, Cmd.none )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl (toKey model) (Url.toString url)
                    )

                External href ->
                    ( model, Nav.load href )

        ( ChangedUrl url, _ ) ->
            ( model, Cmd.none )

        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home GotHomeMsg

        ( _, _ ) ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


toKey : Model -> Nav.Key
toKey page =
    case page of
        Home home ->
            home.key

        Article article ->
            article.key

        NotFound navKey ->
            navKey



-- VIEW


view : Model -> Document Msg
view model =
    let
        viewPage toMsg title content =
            { title = title
            , body =
                [ div [] [ h1 [] [ text title ] ]
                , Html.map toMsg content
                ]
            }
    in
    case model of
        Home home ->
            viewPage GotHomeMsg "Articles" (Home.view home)

        Article article ->
            viewPage GotArticleMsg "Article" (Article.view article)

        NotFound _ ->
            { title = "not found", body = [ h1 [] [ text "NOT FOUND" ] ] }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
