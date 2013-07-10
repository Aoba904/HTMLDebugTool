FS = require "fs"
HTTP = require "http"
QURSTR = require 'querystring'
CP = require 'child_process'

noderoot = ""

localcompile = (files, callback)->
	args = ["-jar", noderoot + "/" + "compiler/closurecompiler.jar", "--warning_level", "QUIET"]

	for url in files
		args.push "--js"
		args.push url

	cc = CP.spawn "java", args

	cc.stdout.on "data", (data)->
		callback false, data.toString('utf-8')

	cc.stderr.on "data", (data)->
		callback data.toString 'utf-8'

	cc.stdin.end()

webcompile = (files, callback, option)->

	code = ""

	for url in files
		code += FS.readFileSync(name, + "\n").toString 'utf-8'

	option = {} if !option

	error = (error)->
		callback error

	client = HTTP.createClient 80, 'closure-compiler.appspot.com'
	client.on "error", error

	request = client.request "POST", "/compile", {

		'host': 'closure-compiler.appspot.com'
		'Content-Type': 'application/x-www-form-urlencoded'

	}

	request.on "error", error

	request.on "response", (r)->
		r.setEncoding "utf8"
		r.on "data", (c)->
			if c is "" or c is "^n"
				compile code, callback, {
              		output_info: 'errors'
              		compilation_level: option.compilation_level
				}

			callback false, c

	request.end QURSTR.stringify({

		js_code: code.toString "utf-8"
		output_info: option.output_info || 'compiled_code'
		compilation_level: option.compilation_level || 'SIMPLE_OPTIMIZATIONS'

	})

YUIcompile = (option, callback)=>

	option = {} if !option
	type = option.type or "css"
	root = if noderoot then option.root + "/" else ""
	args = ["-jar", root + "compiler/yuicompressor.jar", "--type", "css"]

	for url in files
		args.push url

	cc = CP.spawn "java", args

	cc.stdout.on "data", (data)->
		callback false, data.toString 'utf-8'

	cc.stderr.on "data", (data)->
		callback data.toString 'utf-8'

	cc.stdin.end()

compile = (files, option, callback)->

	if !(files instanceof Array)
		return callback "files object is not array."

	option = {} if !option

	if option.type is "css"
		YUIcompile files, callback

	else if option.compiletype or "local" is "local"
		localcompile files, callback

	else
		webcompile files, callback

exports.compile = compile
exports.setRoot = (str)->
	noderoot = str
	noderoot += "/" if noderoot isnt ""