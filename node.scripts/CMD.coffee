CP = require 'child_process'

commands = {}
none = {}

process.stdin.on 'data', (e)->
	e.trim().split('\n').forEach (line)->
        args = line.split ' '
        name = args.shift()

        for val, key in args
        	val = parseValue val

        	if val isnt none
        		args[key] = val

        voidCommand name, args

enableCommandLine = ()->
	process.stdin.resume()
	process.stdin.setEncoding('utf8')

disableCommandLine = ()->
	process.stdin.pause()

log = (str)->
	process.stdout.write str + "\n"

addCommand = (name, func)->
	commands[name] = func

appendCommand = (obj)->
	for key, val of obj
		commands[key] = val

voidCommand = (name, args)=>
    log if !commands[name]
       	"\"" + name + "\" is unknown command."

    else
       	">" + commands[name].apply(null, args)

parseValue = (str)->
	switch str
		when "true" or "false"
			return new Boolean(str);

		when "null"
			return null

		when "undefined"
			return undefined

	if /^[0-9]+$/.test str
		return parseInt str

	else if /^[0-9]+\.[0-9]+$/.test str
		return parseFloat str

	else if /^".*"$/.test str
		return str.replace /"/g, ""

	else if /[\s|\S]+/
		return str

	return none

getArguments = (func)->
	args = func.toString().match(/^function.+\)?/)[0].replace(/^function.*\(/, "").replace(/\).*{/, "").replace(/\s/g, "").split(", ")

Shell = (command, args, callback)=>

	cc = CP.spawn command, args

	cc.stdout.on "data", (data)->
		callback false, data.toString 'utf-8'

	cc.stderr.on "data", (data)->
		callback data.toString 'utf-8'

	cc.stdin.end()

appendCommand {

	help: ()->
		for cmd, val of commands
			log "--" + cmd + " " + getArguments(val).join " "

		""

	$: (command, args)->
		args = [].slice.call arguments
		name = args.shift()

		disableCommandLine()
		Shell name, args, (data)->
			log data
			enableCommandLine()	

}

exports.void = voidCommand
exports.add = addCommand
exports.append = appendCommand
exports.log = log
exports.enable = enableCommandLine
exports.disable = disableCommandLine