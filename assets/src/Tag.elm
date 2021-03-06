module Tag exposing (Tag, tagDecoder, toString)

import Json.Decode as Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (required)



-- TYPE


type alias Tag =
    { id : Int
    , name : String
    }



-- HELPERS


toString : Tag -> String
toString tag =
    tag.name



-- DECODER


tagDecoder : Decoder Tag
tagDecoder =
    succeed Tag
        |> required "id" int
        |> required "name" string
