-- @see https://redbean.dev/
-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
sqlite3 = require"lsqlite3"
db = sqlite3.open_memory()

-- TODO: this is very vulnerable to relative path transversal
zipfile = GetParam("zipfile")
if string.find(zipfile, "%.%.") then
	SetStatus(400)
	SetHeader("Content-Type", "text/plain; charset=utf-8")
	Write("unexpected input")
end

-- @see https://www.sqlite.org/zipfile.html
stmt = db:prepare("SELECT name, mode, mtime, sz, method FROM zipfile(:zipfile)")
stmt:bind_names{ zipfile = zipfile }
SetHeader("Content-Type", "text/html; charset=utf-8")
Write("<dl>\r\n")
for row in stmt:nrows() do
	Write("<dt>name</dt><dd>")
	if row.sz > 0 then
		Write('<a href="/zipcat.lua?zipfile=')
		Write(EscapeHtml(zipfile))
		Write("&name=")
		Write(EscapeHtml(row.name))
		Write('">')
	end
	Write(EscapeHtml(row.name))
	if row.sz > 0 then
		Write("</a>")
	end
	Write("</dd>\r\n<dt>mode</dt><dd>")
	Write(oct(row.mode))
	Write("</dd>\r\n<dt>mtime</dt><dd>")
	Write(FormatHttpDateTime(row.mtime))
	Write("</dd>\r\n<dt>sz</dt><dd>")
	Write(row.sz)
	Write("</dd>\r\n<dt>method</dt><dd>")
	Write(EscapeHtml(row.method))
	Write("</dd>\r\n")
end
Write("</dl>\r\n")
stmt:finalize()