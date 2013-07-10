HTTP = require "http"
FS = require "fs"
Observer = require "./Observer.js"
ClosureCompiler = require "./ClosureCompiler.js"
HTMLParser = require "./HTMLParser.js"
htmlparser = new HTMLParser

modulesource = ""
extension =
	".txt":	 "text/plain"
	".map":	 "text/plain"
	".js":	 "text/javascript"
	".css":	 "text/css"
	".htm":	 "text/html"
	".html": "text/html"
	".png":	 "image/png"
	".jpg":	 "image/jpeg"
	".gif":	 "image/gif"
	".bmp":	 "image/bmp"
	".ico":	 "image/vnd.microsoft.icon"

getExtensionType = (url)->
	m = url.match /\.[^.]+$/
	ext = extension[m[0]] if m.length;

cuttingModule = (source)->
	console.log ":" + modulesource
	return source if modulesource is ""

	source = source.toString "utf-8"
	html = htmlparser.parse source
	script = htmlparser.parse '<script type="text/javascript"></script>'
	html.$("body").append script
	script.innerText = modulesource

	new Buffer html.toString()


create = (port, host, root, callback)->
	root = if root is "" then "./" else root + "/"
	index_html = "index.html"
	index_source = undefined
	modules = []
	stdout = ""

	compileModule = ()->
		ClosureCompiler.compile modules, { type: "local" }, (err, data)->
			if err
				return callback source

			modulesource = data

	log = (str)->
		stdout += str + "\n"
		observer.dispatch "log", { message: str }

	connect = ()->
		log "try create server."
		try
			server.listen port, host, callback.bind server, false, instance
			log "create server to http://" + host + ":" + port	
				
		catch e
			log "<create error> " + e.message
			callback e.message

	instance =
		bindModule: (ary)->
			modules = ary
			compileModule()

		appendModule: (ary)->
			for val in ary
				modules.push(val) if modules.indexOf(val) is -1

			compileModule()

		close: ()->
			server.close()

		on: (type, func)->
			server.on type, func

		bind: (type, func)->
			observer.add type, func

		log: ()->
			return stdout

	observer = new Observer instance, true
	server = HTTP.createServer()

	server.on "request", (req, res)->
		url = root + req.url.replace /^\//, ""
		reqindex = false

		if url is root 
			url = root + index_html
			reqindex = true

		switch req.method
			when "GET"
				FS.readFile url, {}, (err, source)->
					ext = getExtensionType(url)
					if err or !ext
						res.statusCode = 403
						res.end()
						if !/favicon\.ico$/.test url
							log "<responce error: " + url + "> " + err

					else
						stat = FS.statSync url
						if reqindex
							source = cuttingModule source

						res.setHeader "Content-Type", ext + "; charset=utf-8"
						res.setHeader "Content-length", source.length
						res.setHeader "Last-Modified", stat.mtime
						res.end source


			when "HEAD"
				FS.stat url, (err, stat)->
					if err
						log "<responce error: " + data.url + "> " + err

					else
						res.setHeader "Content-Type", getExtensionType(url) + "; charset=utf-8"
						res.setHeader "Last-Modified", stat.mtime

					res.end()

			else
				res.end()

	connect()

exports.create = create