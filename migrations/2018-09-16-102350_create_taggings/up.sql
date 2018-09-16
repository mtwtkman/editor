create table taggings (
  id integer primary key autoincrement,
  tag_id integer not null,
  article_id integer not null,
  constraint uq_taggings unique (tag_id, article_id)
)
;
