use diesel::prelude::*;
use diesel::result::Error;
use diesel::QueryDsl;
use models::article::Article;
use models::schema::articles::dsl::*;
use models::schema::articles::*;
use rocket::http::Status;
use rocket::response::status::NotFound;
use rocket_contrib::Json;
use DbConn;

#[get("/articles")]
pub fn all(conn: DbConn) -> Result<Json<Vec<Article>>, NotFound<String>> {
    articles
        .order(created_at.desc())
        .load::<Article>(&*conn)
        .map(|r| Json(r))
        .map_err(|_| NotFound(format!("")))
}
