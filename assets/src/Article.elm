module Article exposing (Article, Id, articleDecoder, toStringId)

import Json.Decode as Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)



-- TYPE


type alias Id =
    Int


type alias Article =
    { id : Id
    , title : String
    , body : String
    , published : Bool
    , created_at : String
    , updated_at : String
    }



-- HELPER


toStringId : Id -> String
toStringId id =
    String.fromInt id



-- DECODER


articleDecoder : Decoder Article
articleDecoder =
    succeed Article
        |> required "id" int
        |> required "title" string
        |> required "body" string
        |> required "published" bool
        |> required "created_at" string
        |> required "updated_at" string
