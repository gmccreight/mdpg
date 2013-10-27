describe "TagsCtrl", ->
  $httpBackend = null
  $scope = null
  controller = null

  beforeEach module('WnpApp')
  beforeEach inject ($injector) ->

    window.pageName = 'foo-page'

    # Set up the mock http service responses
    $httpBackend = $injector.get("$httpBackend")

    # Get hold of a scope (i.e. the root scope)
    $scope = $injector.get("$rootScope")

    # The $controller service is used to create instances of controllers
    $controller = $injector.get("$controller")
    createController = ->
      $controller "TagsCtrl",
        $scope: $scope

    # stuff specific to this controller
    controller = createController()

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  pageTagsRequestReturns = (valueToReturn) ->
    $httpBackend.expect('GET', '/p/foo-page/tags').respond(valueToReturn)
    $httpBackend.flush()

  tagNames = ->
    _.map($scope.tags, (tag) -> tag.text)

  describe "getting tags", ->

    it "should return the right text and associated tags", ->
      pageTagsRequestReturns(
        [{"text":"great","associated":[["a-first-tag-new",2]]}]
      )
      expect(tagNames()).toEqual(["great"])

  describe "adding", ->

    beforeEach ->
      pageTagsRequestReturns([])

    addTagWithTextAndSuccess = (text, success) ->
      response = if success then {success: ""} else {error: "some error"}
      $httpBackend.expect('POST', '/p/foo-page/tags').respond(response)
      $scope.tagText = text
      $scope.addTag()
      if success
        # The backend is called again on success
        text = $scope.normalizeTagText(text)
        $httpBackend.expect('GET', '/p/foo-page/tags').respond(
          [{"text":text,"associated":[["other-tag",2]]}]
        )
      $httpBackend.flush()

    describe "successfully", ->

      it "should add a well-formed tag token without modification", ->
        addTagWithTextAndSuccess "new-tag", true
        expect(tagNames()).toEqual ["new-tag"]

      it "should collapse any number of spaces from the token into a -", ->
        addTagWithTextAndSuccess "this   that", true
        expect(tagNames()).toEqual ["this-that"]

      it "should remove preceeding and trailing spaces", ->
        addTagWithTextAndSuccess "  cool-tag ", true
        expect(tagNames()).toEqual ["cool-tag"]

      it "should clear any errors", ->
        $scope.error = "pre-existing error"
        addTagWithTextAndSuccess "good", true
        expect($scope.hasError()).toEqual false
        expect($scope.error).toEqual ""

      it "should clear the tag text", ->
        addTagWithTextAndSuccess "new-tag", true
        expect($scope.tagText).toBe ""

    describe "unsuccessfully", ->

      it "should undo add if there was an error", ->
        addTagWithTextAndSuccess "new-tag", false
        expect($scope.tags.length).toEqual 0

      it "should display an error", ->
        addTagWithTextAndSuccess "new-tag", false
        expect($scope.hasError()).toEqual true
        expect($scope.error).toEqual "some error"

  describe "suggestions", ->

    beforeEach ->
      pageTagsRequestReturns([])

    callSuggestAndServerRespondsWith = (response) ->
      $httpBackend.expect('GET',
        '/p/foo-page/tag_suggestions?tagTyped=something').respond(response)
      $scope.suggest "something"
      $httpBackend.flush()

    it "should get suggestions from the server", ->
      callSuggestAndServerRespondsWith {tags: ["cool", "cooler"]}
      expect($scope.error).toEqual ""
      expect($scope.suggestedTags).toEqual ["cool", "cooler"]

    it "should report an error from the server", ->
      callSuggestAndServerRespondsWith {error: "some error message"}
      expect($scope.error).toEqual "some error message"
      expect($scope.suggestedTags).toEqual []
