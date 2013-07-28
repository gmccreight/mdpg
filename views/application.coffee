window.WnpApp = angular.module('WnpApp', ['ngResource'])

WnpApp.factory 'Tag', ['$resource', ($resource) ->
  $resource '/p/:pageName/tags/:tagSlug',
    {pageName:window.pageName, tagSlug:"@tagSlug"},
    {
      getSuggestion: {method:'GET', url:"/p/:pageName/tag_suggestions", params:{tagName:"@tagName"}}
    }
]

WnpApp.controller 'TagsCtrl', ['$scope', 'Tag', ($scope, Tag) ->

  $scope.tags = Tag.query()

  $scope.suggestedTags = []

  $scope.suggest = (foo) ->
    if foo.length <= 2
      return
    tempTag = new Tag()
    successHandler = (data) ->
      if error = data["error"]
        alert error
      else
        console.log data
        $scope.suggestedTags = data.tags
    errorHandler = (e) ->
      alert "sorry, we had an error"
    tempTag.$getSuggestion({tagTyped:$scope.tagText}, successHandler, errorHandler)

  $scope.chooseSuggested = (foo) ->
    $scope.tagText = foo
    $scope.addTag()

  $scope.addTag = (tag) ->
    newTag = new Tag({text:$scope.tagText})
    tagToAdd = angular.copy(newTag)

    successHandler = (data) ->
      if error = data["error"]
        alert error
        $scope.tags = _.without($scope.tags, tagToAdd)
    errorHandler = (e) ->
      alert "sorry, we had an error"
      $scope.tags = _.without($scope.tags, tagToAdd)

    newTag.$save({}, successHandler, errorHandler)
    $scope.tags.push tagToAdd
    $scope.tagText = ""
    $scope.suggestedTags = []

  $scope.destroy = (tag) ->
    tagToPossiblyRestore = angular.copy(tag)
    successHandler = (data) ->
      if error = data["error"]
        alert error
        $scope.tags.push(tagToPossiblyRestore)
    errorHandler = (e) ->
      alert "sorry, we had an error"
      $scope.tags.push(tagToPossiblyRestore)
    tag.$delete({tagSlug:tag.text}, successHandler, errorHandler)
    $scope.tags = _.without($scope.tags, tag)

]
