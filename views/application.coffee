window.WnpApp = angular.module('WnpApp', ['ngResource'])

WnpApp.normalizeToken = (token) ->
  token.replace(/[ ]+/g, " ").trim().replace(/[ ]/g, "-").toLowerCase()

WnpApp.controller 'TokenNameCtrl', ['$scope', ($scope) ->

  $scope.init = (nameToPrefill) ->
    $scope.tokenName = nameToPrefill

  $scope.normalize = ->
    $scope.tokenName = WnpApp.normalizeToken($scope.tokenName)

]

WnpApp.factory 'Tag', ['$resource', ($resource) ->
  $resource '/p/:pageName/tags/:tagSlug',
    {pageName:window.pageName, tagSlug:"@tagSlug"},
    {
      getSuggestion: {method:'GET', url:"/p/:pageName/tag_suggestions",
      params:{tagTyped:"@tagTyped"}}
    }
]

WnpApp.controller 'TagsCtrl', ['$scope', 'Tag', ($scope, Tag) ->

  $scope.tags = Tag.query()

  $scope.suggestedTags = []

  $scope.hasError = ->
    $scope.error != ""

  $scope.setError = (error) ->
    $scope.error = error

  $scope.setError ""

  $scope.suggest = (tagTyped) ->
    $scope.setError ""
    if tagTyped.length <= 1 && tagTyped != "*"
      $scope.suggestedTags = []
    else
      tempTag = new Tag()
      successFunc = (data) ->
        if error = data["error"]
          $scope.setError error
        else
          $scope.suggestedTags = data.tags
      errorFunc = (e) ->
        $scope.setError "sorry, we had a server error"
      tempTag.$getSuggestion({tagTyped:tagTyped}, successFunc, errorFunc)

  $scope.chooseSuggested = (suggestedTagText) ->
    $scope.tagText = suggestedTagText
    $scope.addTag()

  $scope.normalizeTagText = (text) ->
    WnpApp.normalizeToken(text)

  $scope.addTag = ->
    $scope.setError ""

    if $scope.tagText == "" || $scope.tagText == undefined
      $scope.setError "please type something"
      return

    normalizedText = $scope.normalizeTagText($scope.tagText)

    newTag = new Tag({text:normalizedText, associated:[]})
    tagToAdd = angular.copy(newTag)

    successFunc = (data) ->
      if error = data["error"]
        $scope.setError error
        $scope.tags = _.without($scope.tags, tagToAdd)
      else
        $scope.tags = Tag.query()
    errorFunc = (e) ->
      $scope.setError "sorry, we had a server error"
      $scope.tags = _.without($scope.tags, tagToAdd)

    newTag.$save({}, successFunc, errorFunc)
    $scope.tags.push tagToAdd
    $scope.tagText = ""
    $scope.suggestedTags = []

  $scope.associatedToDisplay = (tag) ->
    maxToDisplay = 5
    if tag.associated.length > maxToDisplay
      if tag.showMore
        return tag.associated
      else
        return tag.associated[0..maxToDisplay - 1]
    else
      tag.associated

  $scope.hasMoreAssociatedToDisplay = (tag) ->
    tag.associated.length != $scope.associatedToDisplay(tag).length

  $scope.showMore = (tag) ->
    tag.showMore = true

  $scope.destroy = (tag) ->
    tagToPossiblyRestore = angular.copy(tag)
    successFunc = (data) ->
      if error = data["error"]
        alert error
        $scope.tags.push(tagToPossiblyRestore)
      else
        $scope.tags = Tag.query()
    errorFunc = (e) ->
      alert "sorry, we had an error"
      $scope.tags.push(tagToPossiblyRestore)
    tag.$delete({tagSlug:tag.text}, successFunc, errorFunc)
    $scope.tags = _.without($scope.tags, tag)

]
