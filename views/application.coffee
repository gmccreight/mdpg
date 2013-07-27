window.WnpApp = angular.module('WnpApp', ['ngResource'])

WnpApp.factory 'Tag', ['$resource', ($resource) ->
  $resource '/p/:pageName/tags/:tagName', {pageName:window.pageName, tagName:"@tagName"}
]

WnpApp.controller 'TagsCtrl', ['$scope', 'Tag', ($scope, Tag) ->

  $scope.tags = Tag.query()

  $scope.addTag = ->
    newTag = new Tag({text:$scope.tagText})
    newTag.$save()

    $scope.tags.push angular.copy(newTag)
    $scope.tagText = ""

  $scope.destroy = (text) ->
    tag = _.first(_.filter($scope.tags, (tag) -> tag.text == text))
    if tag
      $scope.tags = _.filter($scope.tags, (t) -> t.text != text)
      tag.tagName = tag.text
      tag.$delete()

]
