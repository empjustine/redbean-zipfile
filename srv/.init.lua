path = require("path")

local function html_import(zip_path)
	size = GetAssetSize(zip_path)
	if size then
		return Write(LoadAsset(zip_path))
	end
end

local function data_uri(mime_type, payload)
	Write("data:")
	Write(EscapeHtml(mime_type))
	Write(";base64,")
	Write(EncodeBase64(payload))
end

local function is_directory(zip_path)
	if zip_path == "/" then
		return true
	end

	if path.isdir("/zip" .. zip_path) then
		return true
	end
end

local function redbean_zip_index()
	html_import(GetPath() .. ".header.html")
	Write("<h2>")
	Write(EscapeHtml(GetPath()))
	Write(
		"</h2><table><thead><tr><th></th><th>name</th><th>modified</th><th>mode</th><th>size</th><th>comment</th></tr></thead><tbody>\r\n"
	)
	for i, current_zip_path in pairs(GetZipPaths(GetPath())) do
		is_in_current_folder =
			(path.dirname(current_zip_path) .. "/"):gsub(
				"%//",
				"/"
			) == GetPath()
		is_not_hiddden = string.sub(
			-- in current dirname
			path.basename(current_zip_path),
			1,
			1
		) ~= "."

		-- @see https://man.archlinux.org/man/sys_stat.h.0p
		-- S_IROTH
		is_others_readable = GetAssetMode(current_zip_path) & 04 == 04

		if is_in_current_folder and is_not_hiddden and is_others_readable then
			Write("<tr><td>")
			-- TODO: improve this later
			-- this "thing" retrieves icons and encode them in data URI pngs if the extension matches
			extension =
				path.basename(current_zip_path):match("^.+(%..+)$") or ""
			image_location = "/.extension_icons/" .. extension .. ".png"
			if GetAssetSize(image_location) then
				Write('<img src="')
				data_uri("image/png", LoadAsset(image_location))
				Write('" />')
			end
			Write('</td><td><a href="')
			Write(EscapePath(current_zip_path))
			Write('">')
			Write(EscapeHtml(path.basename(current_zip_path)))
			if is_directory(current_zip_path) then
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
	html_import(GetPath() .. ".footer.html")
end

function OnHttpRequest()
	if is_directory(GetPath()) then
		redbean_zip_index()
	else
		Route()
	end
end