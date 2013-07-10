class Observer
	constructor: (instance, call)->
		@_listener = {}
		@_self = instance
		@_call = call

	_def: (type)->
		@_listener[type] = [] if !@_listener[type]
		@_listener[type]

	add: (type, func)->
		events = @_def type
		events[type].push func

	remove: (type, func)->
		events = @_def type
		events.splice events.indexOf(func), 1

	dispatch: (type, event)->
		events = @_def type
		for func in events
			func.call @_self, event

		if @_call
			f = @_self["on" + type]
			f() if f

module.exports = Observer