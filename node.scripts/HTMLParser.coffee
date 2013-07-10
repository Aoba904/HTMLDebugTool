class Query
	constructor: ()->


	bind: (name, func)->
		@each (t)->
			t.attaribute["on" + name] = func.toString().replace(/^function.+{|}$/g, "").replace(/\n/g, "")

		@

	attr: (name, val)->
		@each (t)->
			t.attaribute[name] = val

		@

	append: ()->
		t = @[0]
		for tag in arguments
			tag.parentNode = t
			[].push.call t.children, tag

		@

	remove: ()->
		args = arguments
		@each (t)->
			for tag in args
				index = [].indexOf.call @, tag
				[].splice.call(t.children, index, 1) if index is -1

		@

	each: (func)->
		for val, key in @
			func val, key

		@

	filter: (expr)->
		selector.filter @, expr

	find: (expr)->
		selector.exec @, expr

	wrap: (elem)->
		for child in @
			[].push.call elem.children, child if [].indexOf.call(elem.children, child) is -1

		@

	clone: ()->
		query = new Query

		@each (t)->
			[].push.call query, t

		query

	text: (str)->
		for child in @
			child.innerText = str

		@

	html: (str)->
		if str
			html = parser.parse str
			for child in @
				[].push.call child.children, html

			@

		else
			@[0].toString()


class Tag
	constructor: (name, attr, parent)->
		@tagName = name
		@attaribute = attr
		@parentNode = parent
		@children = new Query
		@innerText = ""

	toElement: ()->
		div = document.createElement "div"
		div.innerHTML = @toString()

		return div.children[0]

	$: (str)->
		selector.exec @, str

	toString: ()->
		str = "<" + @tagName

		for key, val of @attaribute
			str += " " + key + '="' + val + '"'

		str += ">" + @innerText

		for val in @children
			str += val.toString()

		if !isEmpty(@tagName)
			str += '</' + @tagName + '>'

		return str

class Selector
	constructor: ()->
		@rgeselector = /[\.|#]\w+|[^\.|#|\s]+/g
		@rgeclass = /^\./
		@rgeid = /^#/
		@base
		@results

	parse: (str)->
		str.match @rgeselector

	filter: (tag, str)->
		tree = @parse str
		@results = new Query

		for val in tree
			@list tag, val

		return @results

	exec: (tag, str)->
		tree = @parse str
		@results = new Query

		for val in tree
			@search tag, val

		return @results

	search: (tag, str)->
		@list tag, str

		for child in @base
			@search child, str

	list: (tag, str)->
		@base = tag.children or tag

		if @rgeclass.test str
			@class str.replace @rgeclass, ""

		else if @rgeid.test str
			@id str.replace @rgeid, ""

		else
			@tag str

	class: (str)->
		for child in @base
			[].push.call @results, child if child.attaribute.class is str

	id: (str)->
		for child in @base
			[].push.call @results, child if child.attaribute.id is str

	tag: (str)->
		for child in @base
			[].push.call @results, child if child.tagName is str

isEmpty = (str)->
	switch str.length
		when 2
			(str is "br") || (str is "hr")

		when 3
			(str is "img") || (str is "col")

		when 4
			(str is "meta") || (str is "link") || (str is "area") || (str is "base")

		when 5
			(str is "input") || (str is "frame") || (str is "embed") || (str is "param")

		when 7
			(str is "isindex")

		when 8
			(str is "basefont")

		else
			false


isSpecal = (str)->
	(str is "style") || (str is "script")

avoidChar = (str, char, count)->
	avoid = 0
	s = ""
	for c in str
		if avoid < count and c is char
			avoid++
		else
			s += c

	s


class Parser
	constructor: ()->
		@rgeTag = /^<\w+(?:\s+[^>]+)?\/?>/
		@rgeEndTag = /^<\/\w+>/
		@rgeAttr = /[^\s<>="]+="(\\w*[^"]*)?"|[^\s<>]+/g
		@regAttrName = /[^\s=>"]+/
		@regStr = /^"(\w*[^"]*)?"/
		@parent = undefined;
		@stack = undefined;
		@stacktab = 0
		@isspecal = false
		@isinstring = false


	parse: (source)->
		@constructor()
		max = source.length
		count = 0
		char = true

		test = false


		while source
			count++

			if count > max
				console.log "maximum stack length!"
				break

			if !@isspecal
				char = true

				if source.indexOf("<!--") is 0
					m = source.indexOf("-->")
					if m >= 0
						char = false
						cmo = source.substring 4, m
						source = source.substring m + 3

				else if source.indexOf("</") is 0
					m = source.match @rgeEndTag
					if m
						char = false
						m = m[0]
						@parseEndTag m
						source = source.substring m.length

				else if source.indexOf("<") is 0
					m = source.match @rgeTag
					if m
						char = false
						m = m[0]
						@parseTag m
						source = source.substring m.length

				if char
					m = source.indexOf("<")
						

					source = if m is -1
						""

					else
						m = m or 1
						@stack.innerText += @parseInnerText(source.substring(0,m )) if @stack
						source.substring m

			else
				source = @parseSpecalText source
				test = true
				@isspecal = false


		return @parent

	parseTag: (str)->

		char = true
		name = undefined
		attr = {}
		lastattr = ""
		inattr = null
		max = str.length
		count = 0

		while str
			char = true
			count++

			if count > max
				console.log "maximum stack length!"
				break

			if /^[a-zA-Z]/.test str
				m = str.match @regAttrName

				if m
					char = false
					m = m[0]

					if !name
						name = m.toLowerCase() 

					else
						lastattr = m.toLowerCase()
						inattr = null
						attr[lastattr] = true

					str = str.substring m.length

			else if str.indexOf('"') is 0
				m = str.match @regStr

				if m
					char = false
					m = m[0]
					attr[inattr] = m.replace(/^"|"$/g, "") if inattr
					str = str.substring m.length

			else if str.indexOf('=') is 0
				char = false
				inattr = lastattr
				str = str.substring 1

			if char
				str = str.substring 1

		tag = new Tag name, attr, @parent
		[].push.call(@parent.children, tag) if @parent
		@isspecal = isSpecal name

		@stack = if isEmpty name
			tag
		else
			@parent = tag

	parseEndTag: (str)->
		name = str.replace(/\/|<|>|\s/g, "").toLowerCase()
		@isspecal = false

		if name is @parent.tagName
			@stack = undefined
			@parent = @parent.parentNode if @parent.parentNode

	parseInnerText: (str, eltab)->
		syntax = true

		str = if /^[\t\r\n]+$/.test str
			if !eltab
				m = str.match /\t/g
				@stacktab = if m then m.length + 1 else 1
				""
			else
				str

		else
			if /\n/.test str
				ary = str.split "\n"
				str = ""
				for val in ary
					syntax = false
					str += "\n" if str isnt ""
					str += @parseInnerText val, true

			str

		str = str.replace /^[\t\r]*\n|\n[\t\r]*$/g, ""

		if syntax
			avoidChar str, "\t", @stacktab

		else
			str

	parseSpecalText: (source)->
		max = source.length
		char = true
		isstrarg = false
		count = 0
		str = ""

		while 1
			count++

			if count > max
				console.log "maximum stack length!"
				break

			char = true
			split = m = source.indexOf('</') + 2

			if m < 0
				str = source
				source = ""
				break

			source.replace /"|\\(?:")/g, (char, len)->
				if len < m and char is '"'
					isstrarg = !isstrarg
				
			str += source.substring 0, split
			source = source.substring split

			if !isstrarg
				str = @parseInnerText str.substring 0, str.length - 2
				source = "</" + source
				break

		@stack.innerText = str if @stack

		source

selector = new Selector
parser = new Parser

module.exports = Parser