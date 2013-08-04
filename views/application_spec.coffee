describe 'Tag resource', ->

  callback = null
  $httpBackend = null

  beforeEach module('WnpApp')

  beforeEach inject(($injector) ->
    window.pageName = 'foo-page'
    $httpBackend = $injector.get("$httpBackend")
    callback = jasmine.createSpy()
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'for the query', inject(($httpBackend, Tag) ->
    $httpBackend.expect('GET', '/p/foo-page/tags').respond('["hello", "smello", "killer"]')
    Tag.query({}, callback)
  )

  it 'for getSuggestion', inject(($httpBackend, Tag) ->
    $httpBackend.expect('GET', '/p/foo-page/tag_suggestions?tagTyped=coo').respond('{tags: ["hello", "smello"]}')
    Tag.getSuggestion({tagTyped: "coo"}, callback)
  )
