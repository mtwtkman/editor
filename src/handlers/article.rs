use diesel::prelude::*;
use diesel::QueryDsl;
use models::{schema, Article, ArticleForm, NewTagging, Tag, Tagging};
use rocket::response::status::{BadRequest, Created, NotFound};
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

#[post("/", format = "application/json", data = "<article>")]
pub fn new(article: Json<ArticleForm>, conn: DbConn) -> Created<Json<ArticleForm>> {
    diesel::insert_into(schema::articles::table)
        .values(&article.0)
        .execute(&*conn)
        .map(|_| Created(format!("success"), Some(Json(article.0))))
        .unwrap()
}

#[derive(Deserialize)]
pub struct UpdateArticle {
    article: ArticleForm,
    tag_ids: Vec<i32>,
}

#[put("/<id>", format = "application/json", data = "<article>")]
pub fn update(
    id: i32,
    article: Json<UpdateArticle>,
    conn: DbConn,
) -> Result<Json<String>, BadRequest<()>> {
    let UpdateArticle { article, tag_ids } = article.0;
    diesel::update(schema::articles::table)
        .filter(schema::articles::id.eq(id))
        .set(&article)
        .execute(&*conn)
        .map_err(|_| BadRequest::<()>(None))
        .and_then(|_| {
            diesel::delete(schema::taggings::table.filter(schema::taggings::article_id.eq(id)))
                .execute(&*conn)
                .expect("Failed to delete article");
            let values: Vec<NewTagging> = tag_ids
                .into_iter()
                .map(|tag_id| NewTagging {
                    article_id: id,
                    tag_id,
                }).collect();
            diesel::insert_into(schema::taggings::table)
                .values(&values)
                .execute(&*conn)
                .expect("Failed to insert data");
            Ok(Json(format!("ok")))
        })
}

#[delete("/<id>")]
pub fn delete(id: i32, conn: DbConn) -> Result<Json<String>, BadRequest<()>> {
    diesel::delete(schema::articles::table.filter(schema::articles::id.eq(id)))
        .execute(&*conn)
        .map_err(|_| BadRequest::<()>(None))
        .map(|_| Json(format!("ok")))
}
