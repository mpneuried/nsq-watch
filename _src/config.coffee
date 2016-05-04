# # Config Module
#
# a collection of shared nsq methods

# **npm modules**
_isFunction = require( "lodash/isFunction" )
_isObject = require( "lodash/isObject" )
_isArray = require( "lodash/isArray" )
_assignIn = require( "lodash/assignIn" )

# **internal modules**

DEFAULTS =
	# **GENERAL**
	# **active** *Boolean* Configuration to (en/dis)abel the nsq recorder
	active: true
	# **namespace** *String* A namespace for the topics. This will be added/removed transparent to the topics. So only topics within this namespace a relevant.
	namespace: null
	
	# **WATCH**
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

	if _isFunction( _get )
		_obj.get = _get
	else
		_obj.value = _get
	Object.defineProperty( context, prop, _obj )
	return

class ConfigNsqWatch
	
	constructor: ( input )->
		for _k, _v of DEFAULTS
			addGetter( _k, _v, @ )
			
		@set( input )
		return
		
	set: ( key, value )=>
		if not key?
			return
		
		if key is "set"
			return
		
		if _isObject( key )
			for _k, _v of key when key.hasOwnProperty( _k )
				@set( _k, _v )
			return
		if _isObject( @[ key ] ) and _isObject( value ) and not _isArray( value ) and not _isFunction( value )
			@[ key ] = _assignIn( true, {}, @[ key ], value )
		else
			@[ key ] = value
		return

module.exports = ConfigNsqWatch
