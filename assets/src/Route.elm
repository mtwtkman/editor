module Route exposing (Route(..), fromUrl, href)

import Article exposing (Id)
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
        , Parser.map Article (s "article" </> int)
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href route =
    Attr.href (toString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url



-- INTERNAL


toString : Route -> String
toString route =
    let
        pieces =
            case route of
                Home ->
                    []

                Article id ->
                    [ "article", String.fromInt id ]
    in
    "#/" ++ String.join "/" pieces
