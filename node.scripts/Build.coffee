fs = require "fs"
HTMLParser = require "./HTMLParser.js"
ClosureCompiler = require "./ClosureCompiler.js"

parser = new HTMLParser

push = (ary, elem)->
	src = elem.attaribute.src
	if /^\/\/|^http:\/\//.test src
		ary.split++ if ary[ary.split].ary.length
		return

	else
		if !ary[ary.split]
			ary[ary.split] = {
				elem: elem
				ary: []
			}

		else
			head.remove elem

		ary[ary.split].ary.push fileroot + "/" + src

Build = (fileroot, callback)->

	datas = {
		html: []
	}

	source = fs.readFile fileroot + "/index.html" , "utf-8", (err, source)->
		if err
			callback err

		html = parser.parse source
		head = html.$ "head"
		body = html.$ "body"
		h_script = head.find "script"
		b_script = body.find "script"

		sources = []
		sources.split = 0
		split = 0

		h_script.each push.bind null, sources
		sources.split++ if sources[sources.split]
		b_script.each push.bind null, sources

		loaded = 0
		load = 0
		error = false

		for ary in sources
			load++

			lambda = (ary)-> 
				ClosureCompiler.compile ary.ary, { type: "js", compiletype: "local" }, (err, data)->
					if err
						error = true
						callback err, data

					if error
						return

					loaded++

					ary.elem.innerText = data

					if load is loaded
							datas.html.push {
								url: "index.html"
								source: html.toString()
							}
						callback false, datas



			lambda ary


exports.build = Build