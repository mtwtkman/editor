use diesel::insert_into;
use diesel::prelude::*;
use diesel::QueryDsl;
use models::{schema, Article, NewArticle, Tag, Tagging};
use rocket::response::status::{BadRequest, NotFound};
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

#[derive(Serialize)]
pub struct OneResponse {
    pub article: Article,
    pub tags: Vec<Tag>,
}

#[get("/<id>")]
pub fn one(id: i32, conn: DbConn) -> Result<Json<OneResponse>, NotFound<String>> {
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
                .map(|tags| Json(OneResponse { article, tags }))
        })
}

#[derive(Serialize)]
pub struct NewResponse {
    pub message: String,
}

#[post("/", format = "application/json", data = "<article>")]
pub fn new(article: Json<NewArticle>, conn: DbConn) -> Result<Json<NewResponse>, BadRequest<()>> {
    insert_into(schema::articles::table)
        .values(&article.0)
        .execute(&*conn)
        .map_err(|_| BadRequest::<()>(None))
        .map(|_| {
            Json(NewResponse {
                message: format!("success"),
            })
        })
}
