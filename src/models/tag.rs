#[derive(Queryable, Deserialize)]
pub struct Tag {
    id: i32,
    name: String,
}
