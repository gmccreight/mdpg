describe 'Tag resource', ->

  callback = null
  $httpBackend = null

  beforeEach module('WnpApp')

  beforeEach inject ($injector) ->
    window.pageName = 'foo-page'
    $httpBackend = $injector.get("$httpBackend")
    callback = jasmine.createSpy()

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'for the query', inject ($httpBackend, Tag) ->
    $httpBackend.expect('GET', '/p/foo-page/tags').respond('["hello", "smello", "killer"]')
    Tag.query({}, callback)

  it 'for getSuggestion', inject ($httpBackend, Tag) ->
    $httpBackend.expect('GET', '/p/foo-page/tag_suggestions?tagTyped=coo').respond('{tags: ["cool", "cooler"]}')
    Tag.getSuggestion({tagTyped: "coo"}, callback)


describe "TagsCtrl", ->
  $httpBackend = null
  $rootScope = null
  createController = null

  beforeEach module('WnpApp')
  beforeEach inject ($injector) ->
    
    window.pageName = 'foo-page'

    # Set up the mock http service responses
    $httpBackend = $injector.get("$httpBackend")
    
    # Get hold of a scope (i.e. the root scope)
    $rootScope = $injector.get("$rootScope")
    
    # The $controller service is used to create instances of controllers
    $controller = $injector.get("$controller")
    createController = ->
      $controller "TagsCtrl",
        $scope: $rootScope

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it "should get suggestions from the server", ->
    controller = createController()
    $httpBackend.expect('GET', '/p/foo-page/tags').respond([])
    $httpBackend.flush()
    $httpBackend.expect('GET', '/p/foo-page/tag_suggestions?tagTyped=cool').respond({tags: ["cool", "cooler"]})
    $rootScope.suggest "cool"
    $httpBackend.flush()
    expect($rootScope.suggestedTags).toEqual ["cool", "cooler"]
