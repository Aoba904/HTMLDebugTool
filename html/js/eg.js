(function (root, definition)
{

	var def = definition.bind(null, root, undefined);

	if (root.define instanceof Function)
	{
		define(def);
	}
	else
	{
		def();

	}

})(

(function () { return this; })(),

function (root, undef)
{

	"use strict";

	var ns = "$eg",
		rq = {};

	function ThrowError(str)
	{

		throw new Error(str);

	}

	function async(func)
	{

		if (root.window)
		{
			if ( document.addEventListener )
			{
				root.document.addEventListener("DOMContentLoaded", func, false);
			}
			else
			{
				root.document.attachEvent("onreadystatechange", func)
			}
		}
		else
		{
			setTimeout(func, 0);
		}

	}

	function toArray(obj)
	{
		
		return [].slice.call(obj);

	}

	function defprop(writable, enumerable, configurable, obj, prop, val)
	{

		Object.defineProperty(obj, prop, {

			value: val,
			writable: writable,
			enumerable: enumerable,
			configurable: configurable

		});

	}

	function defgs(enumerable, configurable, obj, prop, get, set)
	{

		Object.defineProperty(obj, prop, {

			get: get,
			set: set,
			enumerable: enumerable,
			configurable: configurable

		});

	}

	function defprops(writable, enumerable, configurable, obj, descripter)
	{

		for (var prop in descripter)
		{
			defprop(writable, enumerable, configurable, obj, prop, descripter[prop]);
		}

	}

	function getclazz(space, name)
	{

		if (space.__base__ !== undef && space[name] !== undef)
		{
			return space[name];
		}

		if (space[name] === undef)
		{
			ThrowError(ns + ".ClassContext.extend: \"" + name + "\" is not found.");
		}

		return space[name];

	}

	function clone(obj)
	{
		var prop, log;

		log = {};

		for (prop in obj)
		{
			log[prop] = obj[prop];
		}

		return log;

	}

	var forEach = [].forEach || function (func, that)
	{

		var i, len, obj = Object(this);

		for (i = 0, len = this.length; i < len; i++)
		{
			func.call(that, this[i], i, obj);
		}

	}

	var _class_ = (function _x_()
	{

		var prop, o;

		if (!(this instanceof _x_))
		{
			ThrowError(ns + ".Base.prototype.constructor: Not use new operator.");
		}

		if(_x_.__singleton__ instanceof _x_)
		{
			return _x_.__singleton__;
		}

		for (prop in this)
		{
			if (prop !== "constructor")
			{
				defprop(true, true, true, this, prop, this[prop]);
			}
		}

		defprops(true, false, false, this, {
			
			constructor: _x_,
			__super__: _x_

		});

		if (arguments[0] !== rq)
		{
			if (this.__attr__ instanceof Function)
			{
				this.__attr__.call(this);
			}

			if (this.init instanceof Function)
			{
				this.init.apply(this, arguments);
			}
		}

	}).
	toString();

	function Class(name, extend, descripter)
	{

		var clazz = eval("(function () { return " + _class_.replace(/_x_/g, name) + "})();")

		if (descripter === undef)
		{
			clazz.prototype = new Object();
			descripter = extend;
		}
		else
		{
			clazz.prototype = new extend(rq);
		}

		defprops(false, true, true, clazz.prototype, descripter);

		return clazz;

	}

	var Base = Class("Base", {

		parent: (function ()
		{
			
			var callStack = [],
				stack_instance,
				stack_name;

			return function (name, arg)
			{

				if (!(this[name] instanceof Function))
				{
					ThrowError(ns + ".Base.prototype.parent: \"" + name + "\" property is not found.");
				}

				var fl, result, log, app, props, func;

				if (!callStack.length)
				{
					stack_instance = this;
					stack_name = name;
					callStack.push(this.__super__);
					fl = true;
				}

				app = log = this.__super__;

				if (stack_instance !== this)
				{
					stack_instance = this;
					callStack.push(this.__super__);
					stack_name = name;
				}
				else if (stack_name != name)
				{
					fl = true;
					app = callStack[callStack.length - 1];
					stack_name = name;
				}

			
				props = app.prototype;
				func = app.prototype[name];

				for (; props[name] === func ; app = props.__super__, props = app.prototype){}

				this.__super__ = app;
				result = props[name].apply(this, arg);
				this.__super__ = log;

				if (fl)
				{
					callStack.pop();
				}

				return result;

			}

		})(),

		binding: function (name, arg)
		{
			
			var args = toArray(arguments);

			arg.unshift(this);

			return Function.prototype.bind.apply(this[name], args);

		},

		defstatic: (function() {
			
			var num = "__static__";

			return function(prop, val)
			{
			
				var cst = this.constructor;

				if (cst[num + prop] === undef)
				{
					cst[num + prop] = val;
				}

				defgs(true, true, this, prop,
				function ()
				{
					
					return cst[num + prop];

				},
				function (x)
				{
					
					cst[num + prop] = x;

				});

			}

		})(),

		destroy: function ()
		{
			
			var prop;

			for (prop in this)
			{
				if (this[prop] instanceof Base)
				{
					this[prop].destroy();
				}
			}

		}

	}),

	ClassContext = Class("ClassContext", Base, {

		init: function (space, name)
		{

			if (!(space instanceof NameSpace) || !(space[name] instanceof Function))
			{
				ThrowError(ns + ".ClassContext: \"" + name + "\" is not found.");
			}

			this.namespace = space;
			this.clazz = space[name];

		},

		extend: function (name)
		{

			if (typeof (name) == "string")
			{
				this.clazz.prototype = new (getclazz(this.namespace, name))(rq);
			}
			else
			{
				if (name.prototype instanceof this.namespace.__parent__.Base)
				{
					this.clazz.prototype = new name(rq);
				}
				else
				{
					this.clazz.prototype = Object.create(name.prototype, {
						init: {
							
							value: name,
							writable: false,
							enumerable: true,
							configurable: true

						}

					});
				}
			}

			defprop(false, false, false, this.clazz, "base", this.clazz.prototype.constructor);

			return this;

		},

		def: function (descripter)
		{

			defprops(false, true, true, this.clazz.prototype, descripter);

			return this.namespace;

		}

	}),

	NameSpace = Class("SpaceBase", Base, {

		init: function (parent)
		{

			if (parent === undef)
			{
				parent = this;

				defprop(false, true, false, this, "Base", Base);
				defprop(false, true, false, this, "ClassContext", ClassContext);
				defprop(false, true, false, this, "NameSpace", NameSpace);
			}

			defprop(false, false, false, this, "__parent__", parent || this);

		},

		Class: (function () {
			
			var main_class = [];

			async(function ()
			{

				var i, len;

				for (i = 0, len = main_class.length; i < len; i++)
				{
					new main_class[i]();
				}

			});

			return function (name)
			{

				var space = this.__base__ || this,
					clazz = Class(name, this.Base || this.__parent__.Base, {});

				if (this[name] !== undef)
				{
					ThrowError(ns + "NameSpace.Class: \"" + name + "\" is not replace.");
				}

				if (name == "Main")
				{
					main_class.push(clazz);
				}

				defprop(false, true, false, space, name, clazz);

				return new this.__parent__.ClassContext(this, name);

			}

		})(),

		method: function (name, func)
		{
			
			defprop(false, true, false, this.__base__ || this, name, func);

			return this;

		},

		space: function (name)
		{

			var o, space = new NameSpace(this.__parent__);

			if (this[name] !== undef)
			{
				ThrowError(ns + ".NameSpace.space: \"" + name + "\" is not replace.");
			}

			defprop(false, true, false, this.__base__ || this, name, space);
			
			return space.wrap();

		},

		wrap: function()
		{
			var o = Object.create(this, {
				
				__base__: {
					
					value: this,
					writable: false,
					enumerable: false,
					configurable: false

				}

			});

			return o;

		},

		include: function (obj)
		{
			
			var prop;

			for (prop in obj)
			{
				if (prop != "Base" && this[prop] === undef && ((obj[prop] instanceof Function) || (obj[prop] instanceof this.__parent__.SpaceBase)))
				{
					defprop(false, true, false, this, prop, obj[prop]);
				}
			}

			return this;

		},

		search: function (clazz)
		{
			var args = [],
				root = this.__base__ || this;

			if (!(clazz instanceof Function))
			{
				ThrowError(ns + ".NameSpace.prototype.search: \"" + clazz.name + "\" is not a class.")
			}

			(function $(root, prop, child)
			{
				for (prop in root)
				{
					child = root[prop];

					if (child instanceof NameSpace)
					{
						$(child)
					}
					else if ((child instanceof Function) && (child.prototype instanceof clazz))
					{
						args.push(child);
					}
				}

			})(root);

			return args;

		}

	});

	(function (root)
	{

		root.space("Observer").

		Class("Listener").def({

			init: function (obj)
			{

				this.self = obj;
				this.listeners = {};
				this.appendelems = [];

			},

			add: function (type, func)
			{

				var events = this.listeners[type] == undef ? this.listeners[type] = [] : this.listeners[type];

				events.push(func);

			},

			remove: function (type, func)
			{

				var i, events = this.listeners[type] == undef ? [] : this.listeners[type];

				while ((i = events.indexOf(func)) != -1)
				{
					events.splice(i, 1);
				}

			},

			append: function (elem, type, prop)
			{

				var i, len, obj, fl, ary = this.appendelems,

				func = function (event)
				{

					this.call(prop, event);

				}.
				bind(this)

				(elem.addEventListener || elem.attachEvent).call(elem, type, func);

				for (i = 0, len = ary.length; i < len; i++)
				{
					obj = ary[i];

					if (obj.elem === elem)
					{
						obj.childs.push({

							type: type,
							func: func

						});

						fl = true;
					}
				}

				if (!fl)
				{
					ary.push({

						elem: elem,
						childs: [{
							type: type,
							func: func
						}]

					});
				}

			},

			call: function (type, event)
			{

				var i, len, events = this.listeners[type] || [];

				events = [].slice.call(events);

				for (i = 0, len = events.length; i < len; i++)
				{
					events[i].call(this.self, event);
				}

				if (this.self["on" + type] instanceof Function)
				{
					this.self["on" + type](event);
				}

			},

			bind: function (prop)
			{

				return this.call.bind(this, prop);

			},

			destroy: function ()
			{

				this.call("destroy");

				this.listeners = {};

				forEach.call(this.instanceelems, function (obj)
				{

					var elem = obj.elem;

					forEach.call(obj.childs, function (obj)
					{

						(elem.removeEventListener || elem.detachEvent)(obj.type, obj.func);

					});

				});

			}

		});

		root.space("Collection").

		Class("WeakMap").def({
			
			__attr__: function ()
			{
				
				this.defstatic("HIDDEN_NAME", "__weakmap__");

			},

			getHiddenRecord: function (key)
			{
				
				var hiddenRecord = key[this.HIDDEN_NAME];

				if (hiddenRecord && hiddenRecord.key === key)
				{
					return hiddenRecord;
				}

				hiddenRecord = {
					
					key: key,
					gets: [],
					vals: []

				}

				defprop(false, false, false, key, this.HIDDEN_NAME, hiddenRecord);

				return hiddenRecord;

			},

			has: function (key)
			{
				
				return this.get !== undef;

			},

			set: function (key, value)
			{
				
				var hr = this.getHiddenRecord(key),
					i;

				if (hr)
				{
					i = hr.gets.indexOf(this);

					if (i >= 0)
					{
						hr.vals[i] = value;
					}
					else
					{
						hr.gets.push(this);
						hr.vals.push(value);

					}
				}

			},

			get: function (key)
			{
				
				var hr = getHiddenRecord(key),
					i, vs;

				if (hr)
				{
					i = hr.gets.indexOf(this);
					vs = hr.vals[i];
				}

				return vs;

			}

		});

		root.space("Extender").

		Class("Singleton").def({

			__attr__: function ()
			{

				if (this.constructor.__singleton__ === undef)
				{
					defprop(false, false, true, this.constructor, "__singleton__", this);
				}

			},

			destroy: function ()
			{
				
				delete this.constructor.__singleton__;
				this.parent("destroy");

			}

		}).

		Class("Array").def({
			
			push: [].push,
			unshift: [].unshift,
			pop: [].pop,
			shift: [].shift,

			indexOf: [].indexOf,
			lastIndexOf: [].lastIndexOf,

			sort: [].sort,
			reverse: [].reverse,

			slice: [].slice,
			splice: [].splice,

			join: [].join,

			forEach: forEach,

			toString: [].toString,
			valueOf: [].valueOf,

			length: 0

		});

		root.space("File").

		Class("Loader").def({

			__attr__: function ()
			{

				var that = this,
					xhr = this.createXHR();

				this.xhr = xhr;
				this.listener = new root.Observer.Listener(this);
				this.runnable = false;
				this._loadurl = "";
				this._loadedfiles = {};

				xhr.onreadystatechange = function ()
				{
					var flag;

					if (xhr.readyState == 4)
					{
						if (xhr.status == 200)
						{
							if (that._loadedfiles[that._loadurl])
							{
								flag = true;
							}

							that._loadedfiles[that._loadurl] = {
								
								type: xhr.getResponseHeader("Content-Type"),
								url: that._loadurl,
								extension: that._loadurl.match(/\.[^\.]*/)[0].replace(/\./, ""),
								lasttime: +new Date(xhr.getResponseHeader("Last-Modified")),
								loadtime: +new Date(),
								text: xhr.responseText

							}

							if (!flag)
							{
								that.listener.call("response", that._loadedfiles[that._loadurl]);
							}
							else
							{
								that.listener.call("refresh", that._loadedfiles[that._loadurl]);
							}

							that.listener.call("change", that._loadedfiles[that._loadurl]);
						}
						else
						{
							that.listener.call("error", xhr.status);
						}

						that.runnable = false;
					}

				}

			},

			createXHR: function()
			{
				
				return new XMLHttpRequest();

			},

			allRefresh: function()
			{
				
				var prop;

				for (prop in this._loadedfiles)
				{
					this.refresh(this._loadedfiles[prop].url);
				}

			},

			refresh: function(src)
			{
				
				var last;

				this.xhr.open("HEAD", src, false);
				this.xhr.send();

				if (xhr.readyState == 3)
				{
					return;
				}

				last = +new Date(this.xhr.getResponseHeader("Last-Modified"));

				if (last > this._loadedfiles[src].lasttime)
				{
					this.load(src);
				}

			},

			load: function (src, func)
			{
				
				this._loadurl = src;
				this.runnable = true;
				this.xhr.open("GET", src, true);
				this.xhr.send();

				if (func instanceof Function)
				{
					this.listener.add("response", function f(event)
					{

						func.call(this, event)

						this.listener.remove("responce", f);

					});
				}

			},

			response: function (src)
			{
				
				return this._loadedfiles[src];

			}

		});
	
	})
	(root[ns] = new NameSpace());

});