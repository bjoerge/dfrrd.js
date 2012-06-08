Deferred = require('../deferred')
expect = require("expect.js")
sinon = require("sinon")

after = (ms, func)->
  setTimeout(func, ms)

describe "Deferred #{Deferred.VERSION.toString()}", ->

  describe "Instantiation", ->
    it "can be instantiated using new", ->
      d = new Deferred()
      expect(d).to.be.ok()

    it "can be instantiated without the new operator", ->
      d = Deferred()
      expect(d).to.be.ok()
      expect(d.then).to.be.a('function')

  describe "Integrity", ->
    it "Cannot be fulfilled (i.e. resolved or rejected) more than once", ->
      d = Deferred()
      d.resolve()
      expect(d.resolve).to.throwException(/already completed/i)

    it "Synchronously call listeners when they are added if promise is already fullfilled", (done) ->
      spy = sinon.spy()      
      d = Deferred()
      after 10, ->
        d.resolve("win!")
        expect(spy.called).to.be(true)
        d.then(spy)
        expect(spy.calledTwice).to.be(true)        

      d.then(spy)
      expect(spy.called).to.be(false)
      d.always -> done()

    it "Notifies always-listeners after then/success/fail listeners", ->
      spyAlways = sinon.spy()
      spySuccess = sinon.spy()
      d = Deferred()
      d.then(spySuccess)
      d.then ->
        expect(spyAlways.called).to.be(false)
      d.always(spyAlways)
      d.always ->
        expect(spySuccess.called).to.be(true)
      d.resolve()

    it "Notifies listeners in the order they are added", ->
      spies = (sinon.spy() for i in [0...10])
      d = Deferred()
      d.then spies[0]
      d.then -> expect(spies[0].called).to.be(true)
      d.then -> expect(spies[1].called).to.be(false)
      d.then -> expect(spies[2].called).to.be(false)
      d.then spies[1]
      d.then -> expect(spies[0].called).to.be(true)
      d.then -> expect(spies[1].called).to.be(true)
      d.then -> expect(spies[2].called).to.be(false)
      d.then spies[2]
      d.then -> expect(spies[0].called).to.be(true)
      d.then -> expect(spies[1].called).to.be(true)
      d.then -> expect(spies[2].called).to.be(true)
      d.resolve()

  describe "Deferred API", ->
    it "notifies listeners with the argument list passed to resolve", ->
      spy = sinon.spy()
      d = Deferred()
      d.then(spy)
      d.resolve("hipp","hopp")
      expect(spy.calledWith("hipp", "hopp")).to.be(true)

    it "notifies then/success-listeners when resolved", ->
      spy = sinon.spy()
      d = Deferred()
      d.then(spy)
      d.resolve("hepp")
      expect(spy.calledWith("hepp")).to.be(true)

    it "notifies fail-listeners when rejected", ->
      spy = sinon.spy()
      d = Deferred()
      d.fail(spy)
      d.reject("oh noes")
      expect(spy.calledWith("oh noes")).to.be(true)

    it "notifies progress listeners when notified", ->
      spy = sinon.spy()
      d = Deferred()
      d.progress(spy)

      d.notify("oh noes")
      expect(spy.calledWith("oh noes")).to.be(true)

      d.notify("oh noes !!")
      expect(spy.calledWith("oh noes !!")).to.be(true)

      expect(spy.calledTwice).to.be(true)

    it "notifies progress listeners added later", ->
      spy = sinon.spy()
      d = Deferred()
      d.notify("tick 1")
      d.notify("tick 2")
      d.notify("tick 3")

      d.progress(spy)
      
      expect(spy.calledWith("tick 1")).to.be(true)
      expect(spy.calledWith("tick 2")).to.be(true)
      expect(spy.calledWith("tick 3")).to.be(true)
      expect(spy.calledThrice).to.be(true)
      
    it "resolves immediately if Deferred.when is called without any arguments", ->
      d = Deferred()
      spy = sinon.spy()
      Deferred.when().then spy
      expect(spy.calledOnce).to.be(true)

    it "notifies always-listeners when resolved", ->
      d = Deferred()
      spy = sinon.spy()
      d.always(spy)
      d.resolve("hepps")
      expect(spy.calledWith("hepps")).to.be(true)

    it "notifies always-listeners when rejected", ->
      d = Deferred()
      spy = sinon.spy()
      d.always(spy)
      d.reject("oh no!")
      expect(spy.calledWith("oh no!")).to.be(true)

    it "notifies the correct listeners added with then() upon resolve", ->
      spySuccess = sinon.spy()
      spyFailure = sinon.spy()
      spyProgress = sinon.spy()
      spyComplete = sinon.spy()

      d = Deferred()
      d.then(spySuccess, spyFailure, spyProgress, spyComplete)
      d.notify("tick tack")
      d.resolve("Yay")

      expect(spyProgress.calledWith("tick tack")).to.be(true)
      expect(spySuccess.calledWith("Yay")).to.be(true)
      expect(spyFailure.called).to.be(false)
      expect(spyComplete.called).to.be(true)

    it "notifies the correct listeners added with then() upon reject", ->
      spySuccess = sinon.spy()
      spyFailure = sinon.spy()
      spyProgress = sinon.spy()
      spyComplete   = sinon.spy()

      d = Deferred()
      d.then(spySuccess, spyFailure, spyProgress, spyComplete)
      d.notify("tick")
      d.notify("tack")
      d.reject("Bam!")

      expect(spyProgress.calledWith("tick")).to.be(true)
      expect(spyProgress.calledWith("tack")).to.be(true)
      expect(spyProgress.calledTwice).to.be(true)
      expect(spyFailure.calledWith("Bam!")).to.be(true)
      expect(spySuccess.called).to.be(false)
      expect(spyComplete.called).to.be(true)

  describe "Promise API", ->
    it "Lacks mutators", ->
      promise = Deferred().promise()
      expect(promise).not.to.have.property('reject');
      expect(promise).not.to.have.property('resolve');
      expect(promise).not.to.have.property('notify');

    it "notifies listeners as it should", ->
      spySuccess = sinon.spy()
      spyFailure = sinon.spy()
      spyProgress = sinon.spy()
      spyComplete   = sinon.spy()

      d = Deferred()
      promise = d.promise()
      promise.then(spySuccess, spyFailure, spyProgress, spyComplete)
      d.notify("tick")
      d.notify("tack")
      d.reject("Bam!")

      expect(spyProgress.calledWith("tick")).to.be(true)
      expect(spyProgress.calledWith("tack")).to.be(true)
      expect(spyProgress.calledTwice).to.be(true)
      expect(spyFailure.calledWith("Bam!")).to.be(true)
      expect(spySuccess.called).to.be(false)
      expect(spyComplete.called).to.be(true)
      
    it "allows for registering listeners using both deferred api and promise api", ->
      deferredSpy = sinon.spy()
      promiseSpy = sinon.spy()

      Deferred().then(deferredSpy).promise().then(promiseSpy).resolve("Hooray!")

      expect(deferredSpy.calledWith("Hooray!")).to.be(true)
      expect(promiseSpy.calledWith("Hooray!")).to.be(true)
      
  describe "Chainability",->
    it "Resolves only when all chained promises gets resolved", ->
      d1 = Deferred()
      d2 = Deferred()
      d3 = Deferred()
      spy = sinon.spy()
      Deferred.when(d1, d2, d3).then spy
      expect(spy.called).to.be(false)
      d1.resolve()
      expect(spy.called).to.be(false)
      d2.resolve()
      expect(spy.called).to.be(false)
      d3.resolve()
      expect(spy.called).to.be(true)

    it "does not resolve if one of the chained promises gets rejected", ->
      d1 = Deferred()
      d2 = Deferred()
      d3 = Deferred()
      spy = sinon.spy()
      Deferred.when(d1, d2, d3).then spy
      d1.resolve()
      d2.reject()
      d3.resolve()
      expect(spy.called).to.be(false)

    it "passes only rejected values to fail listeners (in the order they were added)", ->
      d1 = Deferred()
      d2 = Deferred()
      d3 = Deferred()
      spy = sinon.spy()
      Deferred.when(d1, d2, d3).fail spy

      d3.resolve("yay3")
      d2.reject("ouch!", "abc")
      d1.resolve("yay1", "yay1.1")

      expect(spy.calledWith(undefined, ['ouch!', "abc"], undefined)).to.be(true)

    it "allows for creating a new chain (which only can be resolved by its individual promises)", ->
      d1 = Deferred()
      d2 = Deferred()
      spy = sinon.spy()
 
      Deferred.chain().join(d1).join(d2).then spy

      d1.resolve()
      d2.resolve()

      expect(spy.called).to.be(true)

    it "Any call to Deferred.when returns a chain", ->
      d1 = Deferred()
      d2 = Deferred()
      d3 = Deferred()
      d4 = Deferred()

      spy = sinon.spy()
      Deferred.when(d1, d2).join(d3, d4).then spy

      d3.resolve('d3')
      d4.resolve('d4')
      d2.resolve('d2')
      d1.resolve('d1')

      expect(spy.calledWith(['d1'], ['d2'], ['d3'], ['d4'])).to.be(true)

    it "A CoffeeScript example destructing arguments (see test/deferred.coffee)", ->
      d1 = Deferred()
      d2 = Deferred()
      d3 = Deferred()
      d4 = Deferred()

      spy = sinon.spy()
      Deferred.when(d1, d2).join(d3, d4).then ([d1, d11], [d2], [d3], [d4]) ->
        expect(d1).to.eql("arg1")
        expect(d11).to.eql("arg2")
        expect(d2).to.eql("d2")
        expect(d3).to.eql("d3")
        expect(d4).to.eql("d4")

      d3.resolve('d3')
      d4.resolve('d4')
      d2.resolve('d2')
      d1.resolve('arg1', 'arg2')
