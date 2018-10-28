module Article exposing (Article, articleDecoder)

import Article.Id as Id exposing (Id)
import Json.Decode as Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)



-- TYPE


type alias Article =
    { id : Id
    , title : String
    , body : String
    , published : Bool
    , created_at : String
    , updated_at : String
    }



-- DECODER


articleDecoder : Decoder Article
articleDecoder =
    succeed Article
        |> required "id" Id.decoder
        |> required "title" string
        |> required "body" string
        |> required "published" bool
        |> required "created_at" string
        |> required "updated_at" string
