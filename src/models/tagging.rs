use diesel::prelude::*;
use models::{taggings, Article, Tag};

#[derive(Identifiable, Queryable, Associations)]
#[belongs_to(Article)]
#[belongs_to(Tag)]
pub struct Tagging {
    pub id: i32,
    pub article_id: i32,
    pub tag_id: i32,
}
