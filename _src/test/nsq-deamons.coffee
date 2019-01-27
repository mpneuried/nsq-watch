spawn = require('child_process').spawn
fs = require( "fs" )
pathHelper = require( "path" )

_isArray = require('lodash/isArray')

_nsqDataPath = pathHelper.resolve( "./.nsqdata/" )

try
	fs.mkdirSync( _nsqDataPath )

LOOKUP_A_HOST = process.env.NSQ_LOOKUP_A_HOST || "0.0.0.0"
LOOKUP_B_HOST = process.env.NSQ_LOOKUP_B_HOST || "0.0.0.0"
NSQ_HOST = process.env.NSQ_HOST || "0.0.0.0"

daemonsConfig = [
	{
		"name": "LOOKUP-A"
		"bin": "nsqlookupd"
		"args": {
			"http-address": LOOKUP_A_HOST + ":4177"
			"tcp-address": LOOKUP_A_HOST + ":4176"
		}
	},{
		"name": "LOOKUP-B"
		"bin": "nsqlookupd"
		"args": {
			"http-address": LOOKUP_B_HOST + ":4179"
			"tcp-address": LOOKUP_B_HOST + ":4178"
		}
	},{
		"name": "NSQ"
		"bin": "nsqd"
		"args": {
			"http-address": NSQ_HOST + ":4157"
			"tcp-address": NSQ_HOST + ":4156"
			"lookupd-tcp-address": [ LOOKUP_A_HOST + ":4176", LOOKUP_B_HOST + ":4160" ]
			"data-path": _nsqDataPath
		}
	}
]

class Deamons extends require( "events" ).EventEmitter
	constructor: ->
		@iRunning = 0
		@running = []
		
		@basepath = pathHelper.resolve( "./node_modules/nsq-bundle/bin/" )
		return
	
	closedOne: =>
		@iRunning--
		@emit "close"
		if @iRunning <= 0
			@emit "closedAll"
		return
	
	start: ( cb )=>
		for deamon in deamons
			@running.push( @create( deamon, @closedOne ) )
			@iRunning++
		
		setTimeout( cb, 1000 )
		return

	lookupdAddresses: ( type="http" )=>
		_ret = []
		for daemon in daemonsConfig when daemon.bin is "nsqlookupd"
			_ret.push daemon.args?[ type + "-address" ]
		
		return _ret
		
	nsqdAddress: ( type="http" )=>
		for daemon in daemonsConfig when daemon.bin is "nsqd"
			return daemon.args?[ type + "-address" ]
		return null
	
	create: ( options, closed )->
		_args = []
		for _k, _v of options.args
			if _isArray( _v )
				for _vs in _v
					_arg = "-" + _k
					if _vs?
						_arg += "=" + _vs
					_args.push _arg
			else
				_arg = "-" + _k
				if _v?
					_arg += "=" + _v
				_args.push _arg
		
		if process.env.NSQLOG
			console.log "✅  START #{ @basepath }/#{options.bin} #{_args.join( " " )}" if process.env.NSQLOG
		else
			console.log "✅  START #{options.name}"
		deamon = spawn( "#{ @basepath }/#{options.bin}", _args )

		deamon.stdout.on "data", ( data )->
			console.log "LOG #{options.name}:", data.toString() if process.env.NSQLOG
			return
			
		deamon.stderr.on "data", ( data )->
			console.error "ERR #{options.name}:", data.toString() if process.env.NSQERR
			return

		deamon.on "close", ( data )->
			console.log "⛔️  STOPPED #{options.name}"
			closed()
			return
		
		return deamon
	
	stop: ( cb )=>
		console.log "STOP deamons!"
		if @iRunning <= 0
			cb()
			return
		
		for rd in @running
			rd.kill()
		
		@on "closedAll", ->
			cb()
			return
		return

module.exports = new Deamons()
	
