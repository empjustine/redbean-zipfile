-- @see https://redbean.dev/
-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
sqlite3 = require("lsqlite3")
db = sqlite3.open_memory()

-- WARNING!
-- this is just an example, to show you what *can* be done with the
-- fsdir virtual table;
-- just because it *can* be done, doesn't mean it's a good idea to do so!

Write(
	"<table><thead><tr><th>name</th><th>mode</th><th>modified</th></tr></thead><tbody>\r\n"
)
-- @see https://sqlite.org/src/file/ext/misc/fileio.c
-- @see https://man.archlinux.org/man/sys_stat.h.0p
-- S_IROTH
stmt =
	db:prepare(
		"SELECT name, mode, mtime FROM fsdir('.') WHERE (name LIKE '%.zip' or name LIKE '%.cbz') and name NOT LIKE '%/.%' and (mode = 0 or mode & 04 = 04) ORDER BY name"
	)
for row in stmt:nrows() do
	Write('<tr><td><a href="/zipls.lua?zipfile=')
	Write(EscapeHtml(row.name))
	Write('">')
	Write(EscapeHtml(row.name))
	Write("</a></td><td>")
	Write(oct(row.mode))
	Write("</td><td>")
	Write(FormatHttpDateTime(row.mtime))
	Write("</td></tr>\r\n")
end
Write("</tbody>\r\n</table>")
stmt:finalize()