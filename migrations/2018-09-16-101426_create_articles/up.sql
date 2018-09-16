create table articles (
  id integer primary key autoincrement not null,
  title text not null,
  body text not null,
  published boolean not null default false,
  created_at timestamp not null default current_timestamp,
  updated_at timestamp not null default current_timestamp
)
;
