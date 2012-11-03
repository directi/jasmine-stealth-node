global.context = global.describe
global.xcontext = global.xdescribe

console.log "global:"
console.log global

describe "jasmine-stealth", ->
  describe "aliases", ->
    it "creates createStub as an alias of createSpy", ->
      expect(jasmine.createStub).toBe jasmine.createSpy

    describe ".stubFor", ->
      context "existing method", ->
        # Given -> { log = (msg) -> return msg
        When -> stubFor(global.console, "log").andReturn(true)
        Then -> global.console.log() == true

      context "non-existing method", ->
        Given -> @obj = { woot: null }
        When -> spyOn(@obj, "woot").andReturn("troll")
        Then -> @obj.woot() == "troll"

  describe "#when", ->
    spy = undefined
    result = undefined
    beforeEach ->
      spy = jasmine.createSpy("my spy")
      result = spy.when("53").thenReturn("winning")

    it "thenReturn returns the spy", ->
      expect(result).toBe spy

    context "the stubbing is unmet", ->
      it "returns undefined", ->
        expect(spy("not 53")).not.toBeDefined()

    context "the stubbing is met", ->
      it "returns the stubbed value", ->
        expect(spy("53")).toEqual "winning"

    context "multiple stubbings exist", ->
      beforeEach ->
        spy.when("pirate",
          booty: [ "jewels", jasmine.any(String) ]
        ).thenReturn "argh!"
        spy.when("panda", 1).thenReturn "sad"

      it "stubs the first accurately", ->
        expect(spy("pirate",
          booty: [ "jewels", "coins" ]
        )).toBe "argh!"

      it "stubs the second too", ->
        expect(spy("panda", 1)).toBe "sad"

    complexType = undefined
    beforeEach ->
      complexType =
        fruits: [ "apple", "berry" ]
        yogurts:
          greek: ->
            "expensive"

    context "complex return types are stubbed", ->
      beforeEach ->
        spy.when("breakfast").thenReturn complexType

      it "stubs precisely the same object", ->
        expect(spy("breakfast")).toBe complexType

    context "complex argument types are stubbed", ->
      beforeEach ->
        spy.when(complexType).thenReturn "breakfast"

      it "satisfies the stubbing", ->
        expect(spy(complexType)).toBe "breakfast"

    context "stubbing with multiple arguments", ->
      beforeEach ->
        spy.when(1, 1, 2, 3, 5).thenReturn "fib"

      it "satisfies that stubbing too", ->
        expect(spy(1, 1, 2, 3, 5)).toBe "fib"

    context "stubbing a conditional call fake", ->
      beforeEach ->
        @fake = jasmine.createSpy("fake")
        spy.when("panda").thenCallFake(@fake)
        spy("panda")

      it "calls the fake function", ->
        expect(@fake).toHaveBeenCalled()

    context "default andReturn plus some conditional stubbing", ->
      beforeEach ->
        spy.andReturn "football"
        spy.when("bored").thenReturn "baseball"

      describe "it doesn't  appear to invoke the spy", ->
        it "hasn't been called yet", ->
          expect(spy).not.toHaveBeenCalled()

        it "has a callCount of zero", ->
          expect(spy.callCount).toBe 0

        it "has nothing in the calls array", ->
          expect(spy.calls.length).toBe 0

        it "has no argsForCall entries", ->
          expect(spy.argsForCall.length).toBe 0

        it "has no mostRecentCall", ->
          expect(spy.mostRecentCall).toEqual {}

      context "stubbing is not satisfied", ->
        it "returns the default stubbed value", ->
          expect(spy("anything at all")).toBe "football"

      context "stubbing is satisfied", ->
        it "returns the specific stubbed value", ->
          expect(spy("bored")).toBe "baseball"

  describe "#whenContext", ->
    Given -> @ctx = "A"
    Given -> @spy = jasmine.createSpy().whenContext(@ctx).thenReturn("foo")

    context "when satisfied", ->
      When -> @result = @spy.call(@ctx)
      Then -> @result == "foo"

    context "when not satisfied", ->
      When -> @result = @spy.call("B")
      Then -> @result == undefined

  describe "#mostRecentCallThat", ->
    spy = undefined
    beforeEach ->
      spy = jasmine.createSpy()
      spy "foo"
      spy "bar"
      spy "baz"

    context "when given a truth test", ->
      result = undefined
      beforeEach ->
        result = spy.mostRecentCallThat((call) ->
          call.args[0] is "bar"
        )

      it "returns the call we want", ->
        expect(result).toBe spy.calls[1]

    context "when the context matters", ->
      result = undefined
      beforeEach ->
        @panda = "baz"
        result = spy.mostRecentCallThat((call) ->
          call.args[0] is @panda
        , this)

      it "returns the call we want", ->
        expect(result).toBe spy.calls[2]

  describe "jasmine.createStubObj", ->
    context "used just like createSpyObj", ->
      beforeEach ->
        @subject = jasmine.createStubObj('foo',['a','b'])
        @subject.a()
        @subject.b()

      it "creates a spy", ->
        expect(@subject.a).toHaveBeenCalled()

      it "creates b spy", ->
        expect(@subject.b).toHaveBeenCalled()

    context "passed an obj literal", ->
      beforeEach ->
        @subject = jasmine.createStubObj 'foo',
          a: 5
          b: -> 8

      it "returns a simple value", ->
        expect(@subject.a()).toBe(5)

      it "invokes a provided function", ->
        expect(@subject.b()).toBe(8)

  describe "jasmine.argThat (jasmine.Matchers.ArgThat)", ->
    context "with when()", ->
      Given -> @spy = jasmine.createSpy()
      Given -> @spy.when(jasmine.argThat (arg) -> arg > 5).thenReturn("YAY")
      Given -> @spy.when(jasmine.argThat (arg) -> arg < 3).thenReturn("BOO")

      Then -> @spy(1) == "BOO"
      Then -> @spy(4) == undefined
      Then -> @spy(8) == "YAY"


    context "with a spy arg, using toHaveBeenCalledWith", ->
      Given -> @spy = jasmine.createSpy()
      When -> @spy(5)
      Then -> expect(@spy).toHaveBeenCalledWith(jasmine.argThat (arg) -> arg < 6)
      Then -> expect(@spy).not.toHaveBeenCalledWith(jasmine.argThat (arg) -> arg > 5)

    context "passes the equals contract", ->
      Then -> true == jasmine.getEnv().equals_(5, jasmine.argThat (arg) -> arg == 5)
      Then -> false == jasmine.getEnv().equals_(5, jasmine.argThat (arg) -> arg == 4)
      Then -> false == jasmine.getEnv().equals_(5, jasmine.argThat (arg) -> arg != 5)

  describe "jasmine.captor, #capture() & .value", ->
    Given -> @captor = jasmine.captor()
    Given -> @spy = jasmine.createSpy()
    When -> @spy("foo!")
    Then( -> expect(@spy).toHaveBeenCalledWith(@captor.capture()))
    .Then( -> @captor.value == "foo!")

    it "readme example", ->
      captor = jasmine.captor()
      save = jasmine.createSpy()

      save({ name: "foo", phone: "123"});

      expect(save).toHaveBeenCalledWith(captor.capture())
      expect(captor.value.name).toBe("foo")

  describe "global.spyOnConstructor", ->
    describe "a simple class", ->
      class global.Pizza
        makeSlice: -> "nah"

      context "spying on the constructor - string method arg", ->
        Given -> @pizzaSpies = spyOnConstructor(global, "Pizza", "makeSlice")
        When -> new Pizza("banz").makeSlice("lol")
        Then -> expect(@pizzaSpies.constructor).toHaveBeenCalledWith("banz")
        Then -> expect(@pizzaSpies.makeSlice).toHaveBeenCalledWith("lol")

      context "spying on the constructor - array method arg", ->
        Given -> @pizzaSpies = spyOnConstructor(global, "Pizza", ["makeSlice"])
        When -> new Pizza("banz").makeSlice("lol")
        Then -> expect(@pizzaSpies.constructor).toHaveBeenCalledWith("banz")
        Then -> expect(@pizzaSpies.makeSlice).toHaveBeenCalledWith("lol")

      context "normal operation", ->
        Given -> @pizza = new Pizza
        Then -> @pizza.makeSlice() == "nah"

    describe "a collaboration", ->
      class global.View
        serialize: ->
          model: new Model().toJSON()
      class global.Model

      context "stubbing the model's method", ->
        Given -> @modelSpies = spyOnConstructor(global, "Model", "toJSON")
        Given -> @subject = new global.View()
        Given -> @modelSpies.toJSON.andReturn("some json")
        When -> @result = @subject.serialize()
        Then -> expect(@result).toEqual
          model: "some json"







