use chrono::NaiveDateTime;
use diesel::prelude::*;
use diesel::result::Error;
use diesel::QueryDsl;
use models::{schema, Article, Tag, Tagging};
use rocket::http::Status;
use rocket::response::status::NotFound;
use rocket::response::Responder;
use rocket_contrib::Json;
use DbConn;

#[get("/")]
pub fn all(conn: DbConn) -> Json<Vec<Article>> {
    let article_list = schema::articles::table
        .order(schema::articles::created_at.desc())
        .load(&*conn)
        .unwrap_or(vec![]);
    Json(article_list)
}

#[get("/<id>")]
pub fn one(id: i32, conn: DbConn) -> Result<Json<(Article, Vec<Tag>)>, NotFound<String>> {
    schema::articles::table
        .find(id)
        .first::<Article>(&*conn)
        .map_err(|_| NotFound(format!("article_id: {}", id)))
        .and_then(|article| {
            Tagging::belonging_to(&article)
                .select(schema::taggings::tag_id)
                .load::<i32>(&*conn)
                .or(Ok(vec![]))
                .and_then(|tag_ids| {
                    schema::tags::table
                        .filter(schema::tags::id.eq_any(&tag_ids))
                        .order(schema::tags::id)
                        .load::<Tag>(&*conn)
                }).or(Ok(vec![]))
                .map(|tags| Json((article, tags)))
        })
}
