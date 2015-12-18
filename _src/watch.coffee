# # NsqWatch Module
# ### extends [Basic](basic.coffee.html)
#
# A checker factory to spin up on checker per node

# **npm modules**
_ = require( "lodash" )

# **internal modules**
Config = require "./config"
Nodes = require 'nsq-nodes'
Checker = require "./checker"

class NsqWatch extends require( "./basic" )
	# ## defaults
	defaults: =>
		@extend super,
			# **ignoreNodes** *String[]|Function* A list of nodes that should be ignored or a function that will called to check the ignored nodes manually
			ignoreNodes: null
			# **namespace** *String* A namespace for the nodes. This will be added/removed transparent to the topics. So only nodes within this namespace a relevant.
			namespace: null
			# **depthKey** *String* The key to grab the depth out of
			depthKey: "depth"

	constructor: ( options )->
		
		@CHECKERS = {}
		
		# set flags
		@ready = false

		super( options )
		
		@debug "config", @config

		_nodesInst = null
		@getter "Nodes", =>
			if not _nodesInst?
				_nodesInst = new Nodes( @config )
			return _nodesInst

		@_start()
		return

	_start: =>
		if @ready
			return

		@Nodes.filter ( node, nname )=>
			if @config.ignoreNodes?
				if _.isArray( @config.ignoreNodes ) and nname in @config.ignoreNodes
					return false
				if _.isFunction( @config.ignoreNodes )
					return @config.ignoreNodes( node, nname )
					
			return true

		@Nodes.list ( err, nodes )=>
			if err
				@log "error", "initial node read"
				# on initial read error retry to read the node after 60 sec
				setTimeout( @read, 60 * 1000 )
				return
			# create initail checkers
			for _node in nodes
				@addChecker( _node )

			# listen to node changes
			@Nodes.on "add", @addChecker
			@Nodes.on "remove", @removeChecker

			@ready = true
			@emit( "ready" )
			return
		return
		
	destroy: ( cb )=>
		@warning "destroy watcher"
		if not @ready
			return
		
		_count = Object.keys( @CHECKERS ).length
		
		@Nodes.deactivate()
		

		@warning "destroy #{_count} checkers"
		for _name, _checker of @CHECKERS
			@CHECKERS[ _name ].destroy =>
				_count--
				if _count <= 0
					@removeAllListeners()
					cb()
				return
		return
			
		return

	addChecker: ( node )=>
		_name = @Nodes.genName( node )
		if @CHECKERS[ _name ]?
			@_handleError( "addChecker", "ECHECKEREXISTS", { node: node } )
			return
		@CHECKERS[ _name ] = new Checker( @, node, @config )
		@CHECKERS[ _name ].on "status", ( stats )=>
			@emit( "status", stats, node )
			@_processStatus( stats, node )
			return

		@CHECKERS[ _name ].on "error", ( err )=>
			@emit( "error", err )
			return

		@CHECKERS[ _name ].start()
		@log "info", "checker ´#{node}´ added"
		return

	removeChecker: ( node )=>
		_name = @Nodes.genName( node )
		if not @CHECKERS[ _name ]?
			@_handleError( "removeChecker", "ECHECKERNOTFOUND", { node: node } )
			return

		@CHECKERS[ _name ].destroy ( err )=>
			if err
				@log "error", "destroy checker", err
				return
			@CHECKERS[ _name ].removeAllListeners()
			delete @CHECKERS[ _name ]
			@log "info", "checker ´#{node}´ destroyed", Object.keys( @CHECKERS )
			return
		return
	
	_processStatus: ( stats, node )=>
		_depthAll = 0
		_depthAllChannels = 0
		_topicChannelDepths = {}
		# only generate and calculate the depth of the given namespace
		for stat in stats when @nsTest( stat.topic_name )
			_topic = @nsRem( stat.topic_name )
			_i = stat[ @config.depthKey ]
			_chcount = {}
			_chdepth = 0
			for ch in stat.channels
				_chcount[ ch.channel_name ] = ch.depth
				_chdepth += ch.depth
			
			_topicChannelDepths[_topic] = _chcount
			_depthAllChannels += _chdepth
			@emit( "topic-depth", _topic, _i, stat, node )
			@emit( "topic-channel-depth", _topic, _chdepth, _chcount, stat, node )
			_depthAll += _i
		
		@emit "depth", _depthAll, stats, node
		@emit "channel-depth", _depthAllChannels, _topicChannelDepths, stats, node
		return

	ERRORS: =>
		return @extend {}, super,
			# Exceptions
			"ECHECKEREXISTS": [ 409, "A checker for the node `<%=node%>` allready exists" ]
			"ECHECKERNOTFOUND": [ 404, "The checker for the node `<%=node%>` was not found" ]

module.exports = NsqWatch
