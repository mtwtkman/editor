use models::tags;

#[derive(Identifiable, Queryable, Serialize, Deserialize)]
pub struct Tag {
    pub id: i32,
    pub name: String,
}
