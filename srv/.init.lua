local function zip_html_import(zip_path)
	local size = GetAssetSize(zip_path)
	if size then
		return Write(LoadAsset(zip_path))
	end
end

local function starts_with(str, start)
	return str:sub(1, #start) == start
end

local function is_zip_directory(zip_path)
	if zip_path == "/" then
		return true
	end

	if path.isdir("/zip" .. zip_path) then
		return true
	end
end

local function on_zip_directory_http_request()
	zip_html_import(GetPath() .. ".header.html")
	Write("<h2>")
	Write(EscapeHtml(GetPath()))
	Write(
		"</h2><table><thead><tr><th></th><th>name</th><th>modified</th><th>mode</th><th>size</th><th>comment</th></tr></thead><tbody>\r\n"
	)
	for i, current_zip_path in pairs(GetZipPaths(GetPath())) do
		local is_in_current_folder = starts_with(GetPath(), current_zip_path)
		local is_inside_nested_folder =
			not string.find(current_zip_path, "/", #GetPath())
		local is_hiddden = string.find(current_zip_path, "/%.")

		-- @see https://man.archlinux.org/man/sys_stat.h.0p
		-- S_IROTH
		local is_others_readable = GetAssetMode(current_zip_path) & 04 == 04

		-- special case allowing 0 if zip metadata is mangled
		local is_zip_mode_mangled =
			GetAssetMode(current_zip_path) == 0 and GetAssetSize(
				current_zip_path
			) > 0

		if is_in_current_folder and not is_inside_nested_folder and not is_hiddden and (is_others_readable or is_zip_mode_mangled) then
			Write("<tr><td>")
			-- TODO: improve this later
			-- this "thing" retrieves icons and encode them in data URI pngs if the extension matches
			local extension =
				path.basename(current_zip_path):match("^.+(%..+)$") or ""
			local image_location = "/.extension_icons/" .. extension .. ".png"
			if GetAssetSize(image_location) then
				Write('<img src="data:image/png;base64,')
				Write(EncodeBase64(LoadAsset(image_location)))
				Write('" />')
			end
			Write('</td><td><a href="')
			Write(EscapePath(current_zip_path))
			Write('">')
			Write(EscapeHtml(path.basename(current_zip_path)))
			if is_zip_directory(current_zip_path) then
				Write("/")
			end
			Write("</a></td><td>")
			Write(
				FormatHttpDateTime(GetAssetLastModifiedTime(current_zip_path))
			)
			Write("</td><td>")
			Write(oct(GetAssetMode(current_zip_path)))
			Write("</td><td>")
			Write(GetAssetSize(current_zip_path))
			Write("</td><td>")
			Write(EscapeHtml(GetAssetComment(current_zip_path) or ""))
			Write("</td></tr>\r\n")
		end
	end
	Write("</tbody>\r\n</table>")
	zip_html_import(GetPath() .. ".footer.html")
end

function OnHttpRequest()
	if is_zip_directory(GetPath()) then
		on_zip_directory_http_request()
	else
		Route()
	end
end

if #arg == 1 then
	ProgramPort(0) -- random listening port
	LaunchBrowser("/zipls.lua?zipfile=" .. EscapeSegment(arg[1]))
end