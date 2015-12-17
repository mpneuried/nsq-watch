# # Config Module
#
# a collection of shared nsq methods

# **npm modules**
_ = require( "lodash" )
extend = require( "extend" )

# **internal modules**

DEFAULTS =
	# **GENERAL**
	# **active** *Boolean* Configuration to (en/dis)abel the nsq recorder
	active: true
	# **clientId** *String|Null* An identifier used to disambiguate this client.
	clientId: null
	# **namespace** *String* A namespace for the topics. This will be added/removed transparent to the topics. So only topics within this namespace a relevant.
	namespace: null
	
	# **WATCH**
	# **ignoreTopics** *String[]|Function* A list of topics that should be ignored or a function that will called to check the ignored topics manually
	ignoreTopics: null
	# **lookupdHTTPAddresses** *Number* Time in seconds to poll the nsqlookupd servers to sync the availible topics
	lookupdPollInterval: 60
	# **lookupdHTTPAddresses** *String[]* A list of nsq lookup servers
	lookupdHTTPAddresses: [ "127.0.0.1:4161", "127.0.0.1:4163" ]

	# **CHECKER**
	# **statusPollInterval** *Number* Time in seconds to poll the nsqlookupd servers for their status
	statusPollInterval: 60 * 3

	logging:
		severity: process.env[ "severity" ] or process.env[ "severity_nsq_watch"] or "warning"
		severitys: "fatal,error,warning,info,debug".split( "," )

addGetter = ( prop, _get, context )=>
	_obj =
		enumerable: true
		writable: true

	if _.isFunction( _get )
		_obj.get = _get
	else
		_obj.value = _get
	Object.defineProperty( context, prop, _obj )
	return

class Config
	
	constructor: ( input )->
		for _k, _v of DEFAULTS
			addGetter( _k, _v, @ )
			
		@set( input )
		return
		
	set: ( key, value )=>
		if not key?
			return
		if _.isObject( key )
			for _k, _v of key
				@set( _k, _v )
			return
		if _.isObject( @[ key ] ) and _.isObject( value ) and not _.isArray( value )
			@[ key ] = extend( true, {}, @[ key ], value )
		else
			@[ key ] = value
		return

module.exports = Config
