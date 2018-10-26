module Request exposing (corsGet)

import Http as Http exposing (Request, emptyBody, expectJson, header, request)
import Json.Decode exposing (Decoder)



-- HELPERS


corsGet : String -> Decoder a -> Request a
corsGet url decoder =
    request
        { method = "get"
        , headers =
            [ header "Access-Control-Allow-Origin" "*"
            , header "Content-Type" "application/json"
            ]
        , url = url
        , body = emptyBody
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
