# Lesswrong Comment Archive
#####A simple tool to archive comments on the website Lesswrong.com

This requires lua.

It also requires cjson and socket. These can be obtained through luarocks:

	luarocks install cjson
	luarocks install socket

To use, open the commandline in the folder and type

	lua scrape.lua username

The script saves a JSON file containing all the comments scraped.

Note that there may be an upper limit on the number of comments you can get. This should be around 2000 commments, though I haven't reached it. To get more than that you would need to scrape every single comment on the site.
