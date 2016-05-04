# # NsqChecker Module
# ### extends [Basic](basic.coffee.html)
#
# a nsq checker for a single topic

# **npm modules**
async = require( "async" )
_isString = require( "lodash/isString" )
request = require( "hyperrequest" )

# **internal modules**

class NsqChecker extends require( "./basic" )

	# ## defaults
	defaults: =>
		@extend super,
			# **statusPollInterval** *Number* Time in seconds to poll the nsqlookupd servers for their status
			statusPollInterval: 60 * 3
			# **lookupdHTTPAddresses** *String[]* A list of nsq lookup servers
			lookupdHTTPAddresses: [ "127.0.0.1:4161", "127.0.0.1:4163" ]
			
	constructor: ( @logger, @node, options )->
		super( options )
		return

	start: =>
		if not @config.active
			@warning "nsq topics disabled"
			return
			
		@fetch()
		
		@_interval = setInterval( @fetch, @config.statusPollInterval * 1000 )
		return

	stop: =>
		clearInterval( @_interval ) if @_interval?
		return

	_prepareUrl: =>
		return "http://" + @node.broadcast_address + ":" + @node.http_port + "/stats?format=json"

	fetch: =>
		if not @config.active
			@warning "nsq checker disabled"
			return
		
		@_fetch ( err, topicstats )=>
			if err
				@emit "error", err
				return

			@emit "status", topicstats
			return
		return

	_fetch: ( cb )=>
		request { url: @_prepareUrl() }, ( err, result )=>
			if err
				@warning "fetch topics", err
				cb( err, null )
				return

			if _isString( result.body )
				_body = JSON.parse( result.body )
			else
				_body = result.body

			if _body.status_code is 200
				cb( null, _body?.data?.topics or [] )
				return
			@error( "invalid-nsq-response", result )
			@_handleError( cb, "EINVALIDRESPONSE" )

			return
		return

	destroy: =>
		@stop()
		return super

	ERRORS: =>
		return @extend {}, super,
			# Exceptions
			"EINVALIDRESPONSE": [ 500, "Received a non 200 response"]

module.exports = NsqChecker
