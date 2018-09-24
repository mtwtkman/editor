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

joinable!(taggings -> articles (article_id));
joinable!(taggings -> tags (tag_id));

allow_tables_to_appear_in_same_query!(
    articles,
    taggings,
    tags,
);
