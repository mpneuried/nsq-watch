# # NsqBasic Module
# ### extends [Basic](basic.coffee.html)
#
# a collection of shared nsq methods

# **npm modules**

# **internal modules**
Config = require "./config"

class NsqBasic extends require( "mpbasic" )()

	constructor: ( options )->
		@connected = false

		@on "_log", @_log

		@getter "classname", ->
			return @constructor.name.toLowerCase()

		# extend the internal config
		if options?.constructor.name is "ConfigNsqWatch"
			@config = options
		else
			@config = new Config( @extend( @defaults(), options ) )

		if not @config.active
			@log "warning", "disabled"
			return

		# init errors
		@_initErrors()

		@initialize( options )

		@debug "loaded"
		return


	active: =>
		return @config.active
			
	activate: =>
		if @config.active
			return false
		@config.active = true
		@connect()
		return true
	
	deactivate: =>
		if not @config.active
			return false
		@config.active = false
		@disconnect()
		return true
	

	destroy: ( cb )=>
		@removeAllListeners()
		cb()
		return
		
	nsTest: ( topic )=>
		if not @config.namespace?
			return true
		return topic[...@config.namespace.length] is @config.namespace
		
	nsRem: ( topic )=>
		if not @config.namespace?
			return topic
		if not @nsTest( topic )
			return topic
		return topic[@config.namespace.length..]
			
	nsAdd: ( topic )=>
		if not @config.namespace?
			return topic
		if @nsTest( topic )
			return topic
		return @config.namespace + topic
			
		
	ERRORS: =>
		return @extend {}, super,
			# Exceptions
			"ENSQOFF": [ 500, "Nsq is currently disabled"]
			"EINVALIDCLIENTID": [ 406, "The given clientId option is invalid. It has to be a String or function returning a string" ]

module.exports = NsqBasic
