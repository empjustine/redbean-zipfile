# redbean zipfile

## run

You can layer (by invoking `redbean` with the flag `-D ${this_folder}`) or
embed (by using `zip redbean.com a-file.lua`) specific parts, or the entire
project, to test the feasibility of `redbean-experiments` for your
application.

- `ls.lua` is a naive listing of all `.zip` in the same `cwd` as your redbean
  instance;

- `zipls.lua` is a naive listing of all contents of a specific zipfile "whole";

- `zipcat.lua` is a naive viewer of the contents of a specific zipfile "file";

## colophon

This is a proof of concept showing how to serve _zipfile_ content that is not
embedded inside [redbean](https://redbean.dev/)'s
[αcτµαlly pδrταblε εxεcµταblε](https://justine.lol/ape.html) zip file.

This of course means that the performance is awful (compared to the 10⁶ops
amazing performance you can get by using redbean the intended way), but it's
still less awful that layers of brittle FUSE hacks, or nested web servers that
\*I\* used before.

My current use for this is some massive (both in document size and document
count) documentation packages that I want to keep in a file-level
random-access container with file-level compression (for now, only
ZIP, but sqlar-compliant sqlite3 databases seems promising).
