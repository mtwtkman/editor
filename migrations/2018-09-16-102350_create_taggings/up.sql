create table taggings (
  id integer primary key autoincrement not null,
  tag_id integer not null references tags(id) on delete cascade,
  article_id integer not null references articles(id) on delete cascade,
  constraint uq_taggings
    unique (tag_id, article_id)
)
;
