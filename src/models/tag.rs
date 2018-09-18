use models::tags;

#[derive(Identifiable, Queryable, Serialize)]
pub struct Tag {
    pub id: i32,
    pub name: String,
}
