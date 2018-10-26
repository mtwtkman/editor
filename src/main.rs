#![feature(plugin)]
#![plugin(rocket_codegen)]
#![feature(custom_attribute)]
#![feature(extern_prelude)]

extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate rocket;
extern crate rocket_contrib;
extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;
extern crate rocket_cors;

use diesel::r2d2::{ConnectionManager, Pool, PooledConnection};
use diesel::SqliteConnection;
use dotenv::dotenv;
use rocket::http::{Method, Status};
use rocket::request::{self, FromRequest};
use rocket::{Outcome, Request, State};
use rocket_cors::{AllowedHeaders, AllowedOrigins};
use std::env;
use std::ops::Deref;

mod handlers;
mod models;

use handlers::{article, tag};

type SqlitePool = Pool<ConnectionManager<SqliteConnection>>;

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

    let allowed_origins = AllowedOrigins::all();

    let options = rocket_cors::Cors {
        allowed_origins: allowed_origins,
        ..Default::default()
    };

    rocket::ignite()
        .mount(
            "/articles",
            routes![
                article::all,
                article::one,
                article::new,
                article::update,
                article::delete,
            ],
        ).mount(
            "/tags",
            routes![tag::all, tag::new, tag::delete, tag::update,],
        ).manage(init_pool(database_url))
        .attach(options)
        .launch();
}
