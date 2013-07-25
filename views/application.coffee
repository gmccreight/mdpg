@TagsCtrl = ($scope) ->

  $scope.tags = [
    text: "learn angular"
    done: true
  ,
    text: "build an angular app"
    done: false
  ]

  $scope.addTag = ->
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
