#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate diesel;
extern crate dotenv;
extern crate rocket;

use diesel::r2d2::{ConnectionManager, Pool, PooledConnection};
use diesel::SqliteConnection;
use dotenv::dotenv;
use rocket::http::Status;
use rocket::request::{self, FromRequest};
use rocket::{Outcome, Request, State};
use std::env;
use std::ops::Deref;

type SqlitePool = Pool<ConnectionManager<SqliteConnection>>;

#[get("/")]
fn index() -> &'static str {
    "Hello, World!"
}

fn init_pool(database_url: String) -> SqlitePool {
    let manager = ConnectionManager::<SqliteConnection>::new(database_url);
    Pool::new(manager).expect("db pool")
}

pub struct DbConn(pub PooledConnection<ConnectionManager<SqliteConnection>>);

impl<'a, 'r> FromRequest<'a, 'r> for DbConn {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<Self, Self::Error> {
        let pool = request.guard::<State<SqlitePool>>()?;
        match pool.get() {
            Ok(conn) => Outcome::Success(DbConn(conn)),
            Err(_) => Outcome::Failure((Status::ServiceUnavailable, ())),
        }
    }
}

impl Deref for DbConn {
    type Target = SqliteConnection;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

fn main() {
    dotenv().ok();
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    rocket::ignite()
        .mount("/", routes![index])
        .manage(init_pool(database_url))
        .launch();
}
