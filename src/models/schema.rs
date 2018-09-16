table! {
    articles (id) {
        id -> Nullable<Integer>,
        title -> Text,
        body -> Text,
        published -> Bool,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

table! {
    taggings (id) {
        id -> Nullable<Integer>,
        tag_id -> Integer,
        article_id -> Integer,
    }
}

table! {
    tags (id) {
        id -> Nullable<Integer>,
        name -> Text,
    }
}

allow_tables_to_appear_in_same_query!(
    articles,
    taggings,
    tags,
);
