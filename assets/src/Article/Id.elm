module Article.Id exposing (Id(..), decoder, encoder, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (int)
import Maybe exposing (andThen)
import Url exposing (Url)
import Url.Parser exposing (Parser, custom)



-- TYPE


type Id
    = Id Int



-- CREATE


urlParser : Parser (Id -> a) a
urlParser =
    custom "ID" <|
        \str -> andThen (\id -> Just (Id id)) (String.toInt str)


decoder : Decoder Id
decoder =
    Decode.map Id Decode.int


encoder : Id -> Encode.Value
encoder id =
    case id of
        Id x ->
            int x



-- HELPER


toString : Id -> String
toString (Id id) =
    String.fromInt id
