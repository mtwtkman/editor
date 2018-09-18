$cmd = $Args[0]
$opt = $Args[1]
$name = "editor"
$de = "docker exec -ti $name"
$cargo = "$de cargo"
$migration = "$de diesel migration"

function go($cmd)
{
  echo $cmd
  iex $cmd
}

switch ($cmd)
{
  "up" {go "docker run -d --rm -ti --name $name -v ${PWD}:/source -w /source -p 55301:55301 $name sh"}
  "sh" {go "$de bash"}
  "build" {go "$de cargo build"}
  "run" {go "$de cargo run"}
  "cargo" {go "$cargo $opt"}
  "sqlite" {go "$de sqlite3 $opt"}
  "diesel" {go "$de diesel $opt"}
  "migration:gen" {go "$migration generate $opt"}
  "migration:run" {go "$migration run"}
  "migration:redo" {go "$migration redo"}
}
