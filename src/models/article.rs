use chrono::NaiveDateTime;
use models::schema::articles;

#[derive(Identifiable, Queryable, Serialize, Deserialize)]
pub struct Article {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Insertable, Serialize, Deserialize, AsChangeset, Queryable)]
#[table_name = "articles"]
pub struct ArticleForm {
    pub title: String,
    pub body: String,
    pub published: Option<bool>,
}
