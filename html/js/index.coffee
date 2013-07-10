sys = $eg.space "UI"

sys.

include($eg.Extender).

method("execute", ()=>

	(new sys.Main).execute()

).
Class("Main").extend(sys.Singleton).def({

	init: ()->
		@message = "HelloWorld"

	execute: ()->
		console.log @message


})