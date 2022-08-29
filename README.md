# redbean-zipfile

## build and run

Run `make` in the project root directory.

- `.init.lua` is a example of how to handle Redbean's embedded zipfile as a
  navigable folder structure.

- `ls.lua` is a naive listing of all `.zip`/`.cbz` in the same current working
  directory as your project;

- `zipls.lua` is a naive listing of all contents of a specific zipfile "whole";

- `zipcat.lua` is a naive viewer of the contents of a specific zipfile "file";

## colophon

This is a proof of concept showing how to serve _zipfile_ content that is, or
is not embedded inside [redbean](https://redbean.dev/)'s
[αcτµαlly pδrταblε εxεcµταblε](https://justine.lol/ape.html) zip file.

This of course means that the performance is awful (compared to the 10⁶ops
amazing performance you can get by using redbean the intended way), but it's
still less awful that layers of brittle FUSE hacks, or nested web servers that
\*I\* used before.

My current use for this is some massive (both in document size and document
count) documentation packages that I want to keep in a file-level
random-access container with file-level compression (for now, only
ZIP, but sqlar-compliant sqlite3 databases seems promising).
