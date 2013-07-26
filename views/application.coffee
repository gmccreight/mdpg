window.WnpApp = angular.module('WnpApp', ['ngResource'])

WnpApp.factory 'Tag', ['$resource', ($resource) ->
  $resource '/p/:pageName/tags/:id', {pageName:window.pageName, id:"@id"}
]

WnpApp.controller 'TagsCtrl', ['$scope', 'Tag', ($scope, Tag) ->

  $scope.tags = Tag.query()

  $scope.addTag = ->
    newTag = new Tag()
    newTag.text = $scope.tagText
    newTag.$save()

    $scope.tags.push
      text: $scope.tagText
    $scope.tagText = ""

]
