use models::tags;

#[derive(Identifiable, Queryable, Serialize, Deserialize)]
pub struct Tag {
    pub id: i32,
    pub name: String,
}

#[derive(Insertable, AsChangeset, Deserialize, Serialize)]
#[table_name = "tags"]
pub struct TagForm {
    pub name: String,
}
