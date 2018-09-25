use diesel::prelude::*;
use diesel::QueryDsl;
use models::schema::tags;
use models::tag::{Tag, TagForm};
use rocket::response::status::{BadRequest, Created};
use rocket_contrib::Json;
use DbConn;

#[get("/")]
pub fn all(conn: DbConn) -> Json<Vec<Tag>> {
    tags::table
        .order(tags::name)
        .load(&*conn)
        .or::<()>(Ok(vec![]))
        .map(|tags| Json(tags))
        .unwrap()
}

#[post("/", format = "application/json", data = "<tag>")]
pub fn new(tag: Json<TagForm>, conn: DbConn) -> Created<Json<TagForm>> {
    diesel::insert_into(tags::table)
        .values(&tag.0)
        .execute(&*conn)
        .map(|_| Created(format!("success"), Some(Json(tag.0))))
        .unwrap()
}

#[put("/<id>", format = "application/json", data = "<tag>")]
pub fn update(id: i32, tag: Json<TagForm>, conn: DbConn) -> Result<Json<String>, BadRequest<()>> {
    diesel::update(tags::table)
        .filter(tags::id.eq(id))
        .set(&tag.0)
        .execute(&*conn)
        .map_err(|_| BadRequest::<()>(None))
        .map(|_| Json(format!("ok")))
}

#[delete("/<id>")]
pub fn delete(id: i32, conn: DbConn) -> Result<Json<String>, BadRequest<()>> {
    diesel::delete(tags::table.filter(tags::id.eq(id)))
        .execute(&*conn)
        .map_err(|_| BadRequest::<()>(None))
        .map(|_| Json(format!("ok")))
}
