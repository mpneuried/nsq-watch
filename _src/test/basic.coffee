# # NsqBasic Module
# ### extends [Basic](basic.coffee.html)
#
# a collection of shared nsq methods

# **npm modules**
_isFunction = require( "lodash/isFunction" )
_isString = require( "lodash/isString" )

# **internal modules**

class NsqBasic extends require( "../basic" )

	fetchClientId: =>
		if _isFunction( @config.clientId )
			_cid = @config.clientId()
			if not _isString( @config.clientId )
				@_handleError( null, "EINVALIDCLIENTID" )
				return
				
			@config.clientId = _cid
			return @config.clientId
		
		if _isString( @config.clientId )
			return @config.clientId
		
		@_handleError( null, "EINVALIDCLIENTID" )
		return @config.clientId

	connect: =>
		if not @config.active
			return

		@_initClient()

		if not @connected
			@disconnecting = false
			@log "info", "try to connect"
			@client.connect()
		return @

	disconnect: =>
		@disconnecting = true
		@client.close()
		return

	reconnect: =>
		# do not reconnect if it's a manual disconnect
		if @disconnecting
			return
		# try a reconnect every 5 sec until the client is online again
		@t_reconnect = setTimeout( =>
			@connect()
			if not @connected
				@reconnect()
			return
		, 5000 )
		return

	onConnect: =>
		@log "debug", "connection established"
		if @t_reconnect?
			clearTimeout(@t_reconnect)

		@connected = true
		@emit( "connected" )
		return

	onDisconnect: =>
		@log "warning", "connection lost" if not @disconnecting
		# if it's currently marked as connected start reconnecting
		if @connected and not @disconnecting
			@reconnect()
		@connected = false
		@emit( "disconnected" )
		return
	
	ERRORS: =>
		return @extend {}, super,
			# Exceptions
			"ENSQOFF": [ 500, "Nsq is currently disabled"]
			"EINVALIDCLIENTID": [ 406, "The given clientId option is invalid. It has to be a String or function returning a string" ]

module.exports = NsqBasic
