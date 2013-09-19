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

  $scope.normalizeTagText = (text) ->
    WnpApp.normalizeToken(text)

  $scope.addTag = ->
    $scope.error = ""

    if $scope.tagText == "" || $scope.tagText == undefined
      $scope.error = "please type something"
      return

    normalizedText = $scope.normalizeTagText($scope.tagText)

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

$ ->

  $("#index_ns_id").find("input").focus()

  $("#page_ns_id").find(".rendered_markdown_cls").dblclick ->
    link = $("#page_ns_id").find(".edit_link_cls")[0]
    window.location = link.href

  $("#page_edit_ns_id").find("textarea").focus()

  $("#page_edit_ns_id").find("textarea").keydown (e) ->
    if (e.keyCode == 13 && e.shiftKey)
      e.preventDefault()
      e.stopPropagation()
      $("#page_edit_ns_id #editing_form_id").submit()
      return false

  $("table.tag_table_cls .name_cls").click ->
    $(this).hide()
    $(this).closest("td").find(".rename_tag_form_cls").show()
