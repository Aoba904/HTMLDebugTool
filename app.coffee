sys = require "sys"
fs = require "fs"
Server = require "./node.scripts/Server.js"
CMD = require "./node.scripts/CMD.js"
Builder = require "./node.scripts/Build.js"
ClosureCompiler = require "./node.scripts/ClosureCompiler.js"

root = "html"
buildroot = "build"
ClosureCompiler.setRoot "node.scripts"
oprtions = {}

fs.readFile "setting.json", "utf-8", (err, data)->
	if err
		sys.log "setting file not found."


	else
		try
			options = JSON.parse data

		catch e
			sys.log 'parse error: "setting.json"'

	Server.create options.port || 3000, options.host || "localhost", root, (err, server)->
		if err
			sys.log err

		else
			sys.log server.log()

			server.bindModule options.scripts || []

			server.onlog = (data)->
				console.log data
				sys.log data.message

			CMD.append {

				"build": ()->
					Builder.build options.root || "html", (err, data)->
						if err
							sys.log "<compile failed>"
							console.log err

						else
							sys.log "compile success."
							for html in data.html
								fd = fs.openSync buildroot + "/" + html.url, "w"
								fs.writeSync fd, html.source, 0, "utf-8"
								fs.closeSync fd

							sys.log "build success."

					"try project building."
							


			}

			CMD.enable()


