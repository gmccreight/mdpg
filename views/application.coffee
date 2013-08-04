window.WnpApp = angular.module('WnpApp', ['ngResource'])

WnpApp.factory 'Tag', ['$resource', ($resource) ->
  $resource '/p/:pageName/tags/:tagSlug',
    {pageName:window.pageName, tagSlug:"@tagSlug"},
    {
      getSuggestion: {method:'GET', url:"/p/:pageName/tag_suggestions", params:{tagTyped:"@tagTyped"}}
    }
]

WnpApp.controller 'TagsCtrl', ['$scope', 'Tag', ($scope, Tag) ->

  $scope.tags = Tag.query()

  $scope.suggestedTags = []

  $scope.hasError = ->
    $scope.error != ""

  $scope.error = ""

  $scope.suggest = (tagTyped) ->
    $scope.error = ""
    if tagTyped.length <= 1 && tagTyped != "*"
      $scope.suggestedTags = []
    else
      tempTag = new Tag()
      successHandler = (data) ->
        if error = data["error"]
          $scope.error = error
        else
          $scope.suggestedTags = data.tags
      errorHandler = (e) ->
        $scope.error = "sorry, we had a server error"
      tempTag.$getSuggestion({tagTyped:tagTyped}, successHandler, errorHandler)

  $scope.chooseSuggested = (suggestedTagText) ->
    $scope.tagText = suggestedTagText
    $scope.addTag()

  $scope.addTag = ->
    $scope.error = ""

    if $scope.tagText == "" || $scope.tagText == undefined
      $scope.error = "please type something"
      return

    normalizedText = $scope.tagText.
      replace(/[ ]+/g, " ").
      trim().replace(/[ ]/g, "-")

    newTag = new Tag({text:normalizedText})
    tagToAdd = angular.copy(newTag)

    successHandler = (data) ->
      if error = data["error"]
        $scope.error = error
        $scope.tags = _.without($scope.tags, tagToAdd)
    errorHandler = (e) ->
      $scope.error = "sorry, we had a server error"
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
