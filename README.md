# Deferred.js

- A simple Promises/A implementation for Node and the browser.

# How to use


### Include it as a dependency in your project's package.json:

```json
"dependencies": {
  "deferred.js": "git://github.com/bjoerge/deferred.js.git#master"
}
```

  Install dependencies

    $ npm install


### Install using npm

    $ npm install git://github.com/bjoerge/deferred.js.git#master


## Node.js

    $ node
    > var Deferred = require("deferred.js")
    > var deferred = new Deferred()
    > deferred.then(function(value) { console.log("Resolved with: ", value) })
    > setTimeout(function() { deferred.resolve("Yay!") }, 1000)
    // ... wait a sec
    > Resolved with:  Yay!

## Browser

Copy deferred.js and include in your project or just hotlink from this repo

    <script src="https://raw.github.com/bjoerge/deferred.js/master/deferred.js"></script>

## Run Mocha tests

  Run tests in Node.js

    $ npm test
    
  Run tests in browser

    $ npm run-script test-browser

## More examples
Check out `test/deferred.coffee` for more examples