-- @see https://redbean.dev/
-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
sqlite3 = require 'lsqlite3';
db = sqlite3.open_memory()


-- WARNING!
-- this is just an example, to show you what *can* be done with the
-- fsdir virtual table;
-- just because it *can* be done, doesn't mean it's a good idea to do so!


Write("<dl>\r\n")
-- @see https://sqlite.org/src/file/ext/misc/fileio.c
stmt = db:prepare("SELECT name, mode, mtime FROM fsdir('.') WHERE name LIKE '%.zip'")
for row in stmt:nrows() do
    Write("<dt>name</dt><dd><a href=\"/zipls.lua?zipfile=" .. EscapeHtml(row.name) .. "\">" .. EscapeHtml(row.name) .. "</a></dd>\r\n")
    Write("<dt>mode</dt><dd>" .. EscapeHtml(row.mode) .. "</dd>\r\n")
    Write("<dt>mtime</dt><dd>" .. EscapeHtml(row.mtime) .. "</dd>\r\n")
end
Write("</dl>\r\n")
stmt:finalize()
