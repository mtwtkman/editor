use diesel::prelude::*;
use models::article::Article;
use models::schema::{articles, taggings, tags};
use models::tag::Tag;

#[derive(Queryable, Associations)]
#[belongs_to(Article)]
#[belongs_to(Tag)]
pub struct Tagging {
    id: i32,
    article_id: i32,
    tag_id: i32,
}
