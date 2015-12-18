nsq-watch
============

[![Build Status](https://secure.travis-ci.org/mpneuried/nsq-watch.png?branch=master)](http://travis-ci.org/mpneuried/nsq-watch)
[![Build Status](https://david-dm.org/mpneuried/nsq-watch.png)](https://david-dm.org/mpneuried/nsq-watch)
[![NPM version](https://badge.fury.io/js/nsq-watch.png)](http://badge.fury.io/js/nsq-watch)

Watch one or many topics for unprocessed messages.

[![NPM](https://nodei.co/npm/nsq-watch.png?downloads=true&stars=true)](https://nodei.co/npm/nsq-watch/)


## Install

```
  npm install nsq-watch
```

## Initialize

```js
new NsqWatch( config );
```

**Example:**

```js
var NsqWatch = require( "nsq-watch" )

var watcher = new NsqWatch({
    topics: ""
});
```

**Config**
- **depthKey** : *( `String` default="depth" )* You can pick the key to emit through the depth event out of the nsqd stats answer.
- **namespace** : *( `String|Null` default=null )* Internally prefix the nsq topics. This will be handled transparent, but with this it's possible to separate different environments from each other. E.g. you can run a "staging" and "live" environment on one nsq cluster.
- **statusPollInterval** : *( `Number` optional: default = `180` )* Time in seconds to poll for node status 
- **lookupdHTTPAddresses** : *( `String|String[]` required )* A single or multiple nsqlookupd hosts. *This is also a configuration of ['nsqjs'](https://github.com/dudleycarr/nsqjs)*
- **lookupdPollInterval** : *( `Number` optional: default = `60` )* Time in seconds to poll the nsqlookupd servers to sync the available nsqwatch. *This is also a configuration of ['nsqjs'](https://github.com/dudleycarr/nsqjs)*
- **active** : *( `Boolean` optional: default = `true` )* Configuration to (de)activate the nsq topics on startup


## Methods

### `.activate()`

Activate the module

**Return**

*( Boolean )*: `true` if it is now activated. `false` if it was already active

### `.deactivate()`

Deactivate the module

**Return**

*( Boolean )*: `true` if it is now deactivated. `false` if it was already inactive

### `.active()`

Test if the module is currently active

**Return**

*( Boolean )*: Is active?

## Events

### `status`

publishes status of a node

**Arguments** 

- **node** : *( `Object` )* A raw node object
- **stats** : *( `Array` )* An raw array of topics stats hold by this node. The topics here will include the namespaces within the name and are not filtered

**Example:**

```js
nsqwatch.on( "status", function( stats, node ){
    // called until new status data where polled
    /*
    STATS: 
    [ { topic_name: 'foo',
        channels: [],
        depth: 2,
        backend_depth: 2,
        message_count: 0,
        paused: false,
        e2e_processing_latency: { count: 0, percentiles: null } },
      { topic_name: 'bar',
        channels: [ "logging" ],
        depth: 0,
        backend_depth: 0,
        message_count: 0,
        paused: false,
        e2e_processing_latency: { count: 0, percentiles: null } },
    
    NODE: 
        { remote_address: '127.0.0.1:49160',
        hostname: 'MyMachineName.local',
        broadcast_address: 'MyMachineName.local',
        tcp_port: 4150,
        http_port: 4151,
        version: '0.3.6',
        tombstones: [ false, false ],
        topics: [ 'foo','bar']
    }
    */
});
```

### `topic-depth`

publishes depth for each topic.
Note: If you are using the `namespace` config. Only the matching topics will be emitted.
The topic will be without the namespace

**Arguments** 

- **topic** : *( `String` )* The topic name (without the `namespace` prefix)
- **depth** : *( `Number` )* The message depth of this topic
- **stats** : *( `Array` )* An raw array of topics stats hold by this node. The topics here will include the namespaces within the name and are not filtered
- **node** : *( `Object` )* A raw node object

**Example:**

```js
nsqwatch.on( "topic-depth", function( topic, depth, stats, node ){
    // called until a new topic arrived
    /*
    TOPIC: foo
    DEPTH: 12
    STATS: raw stats. See example in `status`
    NODE: raw node. See example in `status`
    */
});
```

### `topic-channel-depth`

publishes channel-depth for each topic.
Note: If you are using the `namespace` config. Only the matching topics will be emitted.
The topic will be without the namespace

**Arguments** 

- **topic** : *( `String` )* The topic name (without the `namespace` prefix)
- **channeldepth** : *( `Number` )* Cumulated count of depth over all channels of the topics.
- **channels** : *( `Object` )* An object with the channel name as key and the current depth as value
- **stats** : *( `Array` )* An raw array of topics stats hold by this node. The topics here will include the namespaces within the name and are not filtered
- **node** : *( `Object` )* A raw node object

**Example:**

```js
nsqwatch.on( "topic-depth", function( topic, depth, stats, node ){
    // called until a new topic arrived
    /*
    TOPIC: foo
    CHANNELDEPTH: 65
    CHANNELS: { "fizz-channel": 23, "buzz-channel": 42 } // the sum of all keys is represented by `channeldepth`
    STATS: raw stats. See example in `status`
    NODE: raw node. See example in `status`
    */
});
```

### `depth`

the cumulated depth of all topics matching the `namespace`.

**Arguments** 

- **depth** : *( `Number` )* The depth of all topics matching the namespace
- **stats** : *( `Array` )* An raw array of topics stats hold by this node. The topics here will include the namespaces within the name and are not filtered
- **node** : *( `Object` )* A raw node object

**Example:**

```js
nsqwatch.on( "depth", function( depth, stats, node ){
    // called until a new topic arrived
    /*
    DEPTH: 58
    STATS: raw stats. See example in `status`
    NODE: raw node. See example in `status`
    */
});
```

### `channel-depth`

Get the depth over all topics and channels

**Arguments** 

- **channeldepth** : *( `Number` )* Cumulated count of depth over all channels and topics.
- **channels** : *( `Object` )* An object with the topic name as key and an object of channel depth.
- **stats** : *( `Array` )* An raw array of topics stats hold by this node. The topics here will include the namespaces within the name and are not filtered
- **node** : *( `Object` )* A raw node object

**Example:**

```js
nsqwatch.on( "depth", function( depth, stats, node ){
    // called until a new topic arrived
    /*
    CHANNELDEPTH: 78
    CHANNELS: { "foo-topic":{ "fizz-channel": 23, "buzz-channel": 42 }, "bar-topic":{ "fizz-channel": 13 } }
    STATS: raw stats. See example in `status`
    NODE: raw node. See example in `status`
    */
});
```

### `error`

An error occurred. E.g. called if a invalid filter was used or no lookup server is available

**Arguments** 

- **err** : *( `Error` )* The error object. 

**Example:**

```js
nsqwatch.on( "error", function( err ){
    // handle the error
});
```

### `ready`

Emitted once the list of topics where received the first time.
This is just an internal helper. The Method `list` will also wait for the first response. The events `add`, `remove` and `change` are active after this first response.
**Example:**

```js
nsqwatch.on( "ready", function( err ){
    // handle the error
});
```

## Release History
|Version|Date|Description|
|:--:|:--:|:--|
|0.0.4|2015-12-18|added channel depths|
|0.0.3|2015-12-18|added config to set the depth key|
|0.0.2|2015-12-18|added depth events and handles namespace|
|0.0.1|2015-12-17|Initial commit|

[![NPM](https://nodei.co/npm-dl/nsq-watch.png?months=6)](https://nodei.co/npm/nsq-watch/)

> Initially Generated with [generator-mpnodemodule](https://github.com/mpneuried/generator-mpnodemodule)

## The MIT License (MIT)

Copyright © 2015 M. Peter, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
