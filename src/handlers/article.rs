use chrono::NaiveDateTime;
use diesel::prelude::*;
use diesel::result::Error;
use diesel::QueryDsl;
use models::{schema, Article, Tag, Tagging};
use rocket::http::Status;
use rocket::response::status::NotFound;
use rocket_contrib::Json;
use DbConn;

#[get("/articles")]
pub fn all(conn: DbConn) -> Json<Vec<Article>> {
    let article_list = schema::articles::table
        .order(schema::articles::created_at.desc())
        .load(&*conn)
        .unwrap();
    Json(article_list)
}

#[get("/articles/<id>")]
pub fn one(id: i32, conn: DbConn) -> Json<(Article, Vec<Tag>)> {
    let article: Article = schema::articles::table
        .find(id)
        .first::<Article>(&*conn)
        .map_err(|_| NotFound("oh".to_string()))
        .unwrap();
    let tag_ids: Vec<i32> = Tagging::belonging_to(&article)
        .select(schema::taggings::tag_id)
        .load::<i32>(&*conn)
        .map_err(|_| NotFound("oh".to_string()))
        .unwrap();
    schema::tags::table
        .filter(schema::tags::id.eq_any(&tag_ids))
        .order(schema::tags::id)
        .load::<Tag>(&*conn)
        .map_err(|_| NotFound("oh".to_string()))
        .map(|tags| Json((article, tags)))
        .unwrap()
}
