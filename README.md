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

- **lookupdHTTPAddresses** : *( `String|String[]` required )* A single or multiple nsqlookupd hosts. *This is also a configuration of ['nsqjs'](https://github.com/dudleycarr/nsqjs)*
- **lookupdPollInterval** : *( `Number` optional: default = `60` )* Time in seconds to poll the nsqlookupd servers to sync the available nsqwatch. *This is also a configuration of ['nsqjs'](https://github.com/dudleycarr/nsqjs)*
- **topicFilter** : *( `Null|String|Array|RegExp|Function` optional: default = `null` )* A filter to reduce the returned topics
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

### `add`

A new topic was added

**Arguments** 

- **topic** : *( `String` )* The new topic

**Example:**

```js
nsqwatch.on( "add", function( topic ){
    // called until a new topic arrived
});
```

### `remove`

A existing topic was removed

**Arguments** 

- **topic** : *( `String` )* The removed topic

**Example:**

```js
nsqwatch.on( "remove", function( topic ){
    // called until a topic was removed
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
|0.0.1|2015-11-27|Initial commit|

[![NPM](https://nodei.co/npm-dl/nsq-watch.png?months=6)](https://nodei.co/npm/nsq-watch/)

> Initially Generated with [generator-mpnodemodule](https://github.com/mpneuried/generator-mpnodemodule)

## The MIT License (MIT)

Copyright © 2015 M. Peter, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
