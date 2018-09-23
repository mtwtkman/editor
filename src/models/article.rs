use chrono::NaiveDateTime;
use models::schema::articles;

#[derive(Identifiable, Queryable, Serialize)]
pub struct Article {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Insertable, Deserialize)]
#[table_name = "articles"]
pub struct NewArticle {
    pub title: String,
    pub body: String,
    pub published: Option<bool>,
}
