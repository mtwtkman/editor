table! {
    articles (id) {
        id -> Integer,
        title -> Text,
        body -> Text,
        published -> Bool,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

table! {
    taggings (id) {
        id -> Integer,
        tag_id -> Integer,
        article_id -> Integer,
    }
}

table! {
    tags (id) {
        id -> Integer,
        name -> Text,
    }
}

allow_tables_to_appear_in_same_query!(
    articles,
    taggings,
    tags,
);
