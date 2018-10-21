module Page.Article exposing (Model)

import Article exposing (Article)
import Browser.Navigation as Nav



-- MODEL


type alias Model =
    { article : Article
    , key : Nav.Key
    }
