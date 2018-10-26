module Route exposing (Route(..), fromUrl, href)

import Article.Id as Id exposing (Id)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, top)



-- ROUTING


type Route
    = Home
    | Article Id


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map Article (s "articles" </> Id.urlParser)
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser



-- INTERNAL


routeToString : Route -> String
routeToString route =
    let
        pieces =
            case route of
                Home ->
                    []

                Article id ->
                    [ "articles", Id.toString id ]
    in
    "/#/" ++ String.join "/" pieces
