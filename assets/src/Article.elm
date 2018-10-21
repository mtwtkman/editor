module Article exposing (Article, Id)

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
