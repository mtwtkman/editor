module Const exposing (article_endpoint)

import Url.Builder exposing (absolute)


host : String
host =
    "http://localhost:55301"


article_endpoint : String
article_endpoint =
    String.join "/" [ host, "articles" ]
