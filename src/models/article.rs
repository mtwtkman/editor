use chrono::NaiveDateTime;
use models::articles;

#[derive(Identifiable, Queryable, Serialize)]
pub struct Article {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
