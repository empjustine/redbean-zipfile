-- @see https://redbean.dev/
-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
-- @see https://sqlite.org/src/file/ext/misc/fileio.c
-- @see https://man.archlinux.org/man/sys_stat.h.0p
Write(
	"<table><thead><tr><th>name</th><th>mode</th><th>modified</th></tr></thead><tbody>\r\n"
)

if #arg > 0 then
	for i, row in ipairs(arg) do
		if path.isfile(row) then
			Write("<tr><td>")
			Write(EscapeHtml(row))
			Write(' - <a href="/zipls.lua?zipfile=')
			Write(EscapeParam(row))
			Write('">as zip</a> - <a href="/sqlarls.lua?sqlar=')
			Write(EscapeParam(row))
			Write('">as sqlar</a>')
			Write("</td><td>?</td><td>?</td></tr>\r\n")
		end
	end
else
	local sqlite3 = require("lsqlite3")
	local db = sqlite3.open_memory()
	local stmt =
		db:prepare(
			"SELECT name, mode, mtime FROM fsdir('.') WHERE (name LIKE '%.zip' or name LIKE '%.cbz') and name NOT LIKE '%/.%' and (mode = 0 or mode & 04 = 04) ORDER BY name"
		)
	for row in stmt:nrows() do
		Write('<tr><td><a href="/zipls.lua?zipfile=')
		Write(EscapeParam(row.name))
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
end