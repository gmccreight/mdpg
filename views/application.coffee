window.WnpApp = angular.module('WnpApp', ['ngResource'])

WnpApp.factory 'Tag', ['$resource', ($resource) ->
  $resource '/page_tags/:id', id: '@id'
]

WnpApp.controller 'TagsCtrl', ['$scope', 'Tag', ($scope, Tag) ->

  $scope.tags = Tag.query()

  $scope.addTag = ->

    newTag = new Tag({text:$scope.tagText, done:false})
    newTag.text = $scope.tagText
    newTag.$save()

    $scope.tags.push
      text: $scope.tagText
      done: false
    $scope.tagText = ""

  $scope.remaining = ->
    count = 0
    angular.forEach $scope.tags, (tag) ->
      count += (if tag.done then 0 else 1)
    count

  $scope.archive = ->
    oldTags = $scope.tags
    $scope.tags = []
    angular.forEach oldTags, (tag) ->
      $scope.tags.push tag  unless tag.done

]
