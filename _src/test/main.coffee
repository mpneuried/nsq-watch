should = require('should')
_ = require('lodash')

config = require( "../config" )

utils = require( "./utils" )

testServers = require( "./nsq-deamons" )
testData = require( "./data" )
TestWriter = require( "./writer" )
NsqWatch = require( "../." )

CNF =
	clientId: "mochaTest"
	lookupdPollInterval: 1
	logging: {}
	lookupdHTTPAddresses: [ "localhost:4161", "localhost:4163" ]


watcher = null
writer = null
config = null


describe "----- nsq-watcher TESTS -----", ->
	
	before ( done )->
		#testServers.stop ->
		testServers.start ->
			watcher = new NsqWatch( _.extend( {}, CNF ) )

			config = watcher.config
			
			writer = new TestWriter( "clientId": "watchtest")
			writer.on "connected", =>
				done()
				return
			writer.connect()
			return
		return
	
	after ( done )->
		@timeout( 10000 )
		testData.cleanup config.lookupdHTTPAddresses, ->
			watcher.destroy ->
				testServers.stop( done )
				return
			return
		return


	describe 'Main Tests', ->
		it "wait for a single message", ( done )->
			@timeout( 10000 )
			
			watcher.on "status", ( node, data )->
				console.log node, data
				#done()
				return

			_topic = testData.newTopic()
			_data = utils.randomString( 1024 )
			writer.publish( _topic, _data )
			return
			
		return
	return

