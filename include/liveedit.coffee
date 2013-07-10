context =
	init: (sync)->
		@xhr = new XMLHttpRequest
		@resourceurl = []
		@resources = {}
		@regexp = /\.com\/|\.jp\/|\.net\//

		@resourceurl.push window.location.href

		for child in document.head.children
			if child.tagName is "SCRIPT"  and  child.src isnt "" and !@regexp.test(child.src)
				@resourceurl.push child.src

			if child.tagName is "LINK" and child.href isnt "" and !@regexp.test(child.href)
				@resourceurl.push child.href

		setInterval(()=>
			@refresh()
		, sync || 500)

	refresh: ()->
		for url in @resourceurl
			@xhr.open("HEAD", url, false)
			@xhr.send()

			if @xhr.readyState == 3
				return;

			last = +new Date @xhr.getResponseHeader "Last-Modified"

			if isNaN(last)
				last = 0

			if @resources[url] isnt undefined and @resources[url] isnt last
				window.location.reload true

			@resources[url] = last

context.init(500)