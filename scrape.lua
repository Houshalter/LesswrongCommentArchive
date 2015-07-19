username = arg[1]

cjson = require 'cjson'
local http = require("socket.http")
require 'socket'
http.USERAGENT = "/u/"..username.." - personal comment scraper"

function save(filename, data)
	local file = assert(io.open(filename, "w"))
	file:write(data)
	file:close()
end

function sleep(sec)
    socket.select(nil, nil, sec)
end

function scrapeUserComments(user)
	local allComments = {}
	local after
	while true do
		local afterParam = ''
		if after then
			afterParam = 'after='..after
		end
		local url = 'http://www.lesswrong.com/user/'..user..'/comments/.json?'..afterParam..'&limit=100'
		print(url)
		local txtdata, statusCode = http.request(url)
		if ((not txtdata) or (statusCode ~= 200)) then error("request failed "..statusCode) end
		local data = cjson.decode(txtdata)
		local comments = proccess(data, user)
		concat(allComments, comments)
		print("Successfully scraped "..tostring(#allComments).." comments")
		if #comments == 0 then break end
		after = comments[#comments].data.name
		--print(after)
		sleep(2)
	end
	return allComments
end

function proccess(comments, user)
	local pcomments = {}
	if (comments.data.author == user) then
		table.insert(pcomments, comments)
	end
	if comments.data.replies == cjson.null then comments.data.replies = nil end
	if comments.data.replies then concat(pcomments, proccess(comments.data.replies, user)) end
	local children = comments.data.children
	if children then
		for i,comment in ipairs(children) do
			concat(pcomments, proccess(comment, user))
		end
	end
	comments.data.children = nil
	comments.data.replies = nil
	return pcomments
end

function concat(t, t2)
	for i,v in ipairs(t2) do
		table.insert(t,v)
	end
end
local comments = cjson.encode(scrapeUserComments(username))
local date = os.date():sub(1,8):gsub("/",'-')
save('./scrapedLesswrongComments-'..date..'.json', comments)