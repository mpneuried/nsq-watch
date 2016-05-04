should = require('should')

_assignIn = require( "lodash/assignIn" )
_map = require( "lodash/map" )

config = require( "../config" )

utils = require( "./utils" )

testServers = require( "./nsq-deamons" )
TestWriter = require( "./writer" )
NsqWatch = require( "../." )

CNF =
	clientId: "mochaTest"
	lookupdPollInterval: 1
	statusPollInterval: 1
	logging: {}
	lookupdHTTPAddresses: [ "localhost:4161", "localhost:4163" ]
	namespace: "nsqwatch_"

testData = require( "./data" )( CNF.namespace )

watcher = null
writer = null
config = null


describe "----- nsq-watcher TESTS -----", ->
	
	before ( done )->
		#testServers.stop ->
		testServers.start ->
			watcher = new NsqWatch( _assignIn( {}, CNF ) )

			config = watcher.config
			
			writer = new TestWriter( "clientId": "watchtest", namespace: CNF.namespace )
			writer.on "connected", =>
				done()
				return
			writer.connect()
			return
		return
	
	after: ( done )->
		testData.cleanup config.lookupdHTTPAddresses, ->
			watcher.destroy ->
				testServers.stop( done )
				return
			return
		return


	describe 'Main Tests', ->
		it "wait for a single message", ( done )->
			@timeout( 5000 )
			
			_check = ( stats, node )->
				_map( stats, "topic_name" ).should.containEql( CNF.namespace + _topic )
				watcher.removeListener( "status", _check )
				done()
				return
			
			watcher.on "status", _check

			_topic = testData.newTopic()
			_data = utils.randomString( 1024 )
			writer.publish( _topic, _data )
			return

		it "wait for a `topic-depth` event.", ( done )->
			@timeout( 10000 )
			_check = ( topic, depth, node )->
				if topic is _topic
					depth.should.be.aboveOrEqual( 1 )
					watcher.removeListener( "topic-depth", _check )
					done()
				return
			
			watcher.on( "topic-depth", _check )
			
			_topic = testData.newTopic()
			_data = utils.randomString( 1024 )
			writer.publish( _topic, _data )
			return
		
		it "wait for a `depth` event.", ( done )->
			@timeout( 5000 )
			
			
			_check = ( depth, node )->
				depth.should.be.aboveOrEqual( 3 )
				watcher.removeListener( "depth", _check )
				done()
				return

			watcher.on "depth", _check
			
			_topic = testData.newTopic()
			_data = utils.randomString( 1024 )
			writer.publish( _topic, _data )
			return
			
		return
	return
