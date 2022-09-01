# redbean-zipfile

## build and run

Run `make` in the project root directory.

`redbean-zipfile.com` web server has several examples to be further customized:

- `.init.lua` is a example of how to handle Redbean's embedded zipfile as a
  navigable folder structure.

  It also contains code to handle automatically open zipfiles passed as
  command line parameters.

- `filels.lua`

  - if `[files ...]` are provided as a command line parameter to
    `redbean-zipfile.com`, `filels.lua` will list the allowlist authorized
    files.

  - If no command line parameters are provided to `redbean-zipfile.com`, it is
    a naive listing of all `.zip`/`.cbz`/`.db`/`.sqlar` in the current working
    directory;

- `zipls.lua` is a naive listing of all contents of a specific zipfile "whole";


- `zipcat.lua` is a naive viewer of the contents of a specific zipfile file;


- `datazip.lua` is a naive reimplementation of
  [https://datasette.io/](https://datasette.io/) .

  Read more about the amazing ideas behind datasette.io in those articles:

  - https://simonwillison.net/2017/Nov/13/datasette/

  - https://simonwillison.net/2018/May/20/datasette-facets/

  - https://simonwillison.net/2018/Oct/4/datasette-ideas/

  - https://architecturenotes.co/datasette-simon-willison/

  ### Command line parameters:

  - `serve` is mandatory to enable datazip sqlite3 handling;

  - `--cors` enables cross-origin requests. For more details, see the
    [datasette.io documentation](https://docs.datasette.io/en/stable/json_api.html#json-api);

  - `[files ...]` programs datazip's allowlist of `files` to handle.

  (For example, `./redbean-zipfile.com serve github.db` )

  ### Query string parameters:

  - `database` is sqlite3 databse file, previously added in the allowlist by
    the command line parameters;

  - `sql` is a Structured Query Language query statement;

  - adittional parameters are used as named query statement parameters.

  ( For example,
  http://127.0.0.1:8080/datazip.lua?database=github.db&sql=select%20*%20from%20licenses )

### `redbean-zipfile.com` Command line parameters:

- `[file]` if a single filename is provided in the command line,
  `redbean-zipfile.com` `.init.lua` is setup to open `zipls.lua`
  in your browser, as a zip content visualizer.

### `redbean-zipfile.com` `/filels.lua` Command line parameters:

- `[files ...]` if filenames are provided in the command line, `filels.lua`
  will only list those.

## colophon

This is a proof of concept showing how to serve _zipfile_ and _sqlite3_ content
that might or not be embedded inside [redbean](https://redbean.dev/)'s
[αcτµαlly pδrταblε εxεcµταblε](https://justine.lol/ape.html) zip file.

This of course means that the performance is awful (compared to the 10⁶ops
amazing performance you can get by using redbean the intended way), but it's
still less awful that layers of brittle FUSE hacks, or nested web servers that
\*I\* used before.

My current use for this is some massive (both in document size and document
count) documentation packages that I want to keep in a file-level
random-access container with file-level compression.
