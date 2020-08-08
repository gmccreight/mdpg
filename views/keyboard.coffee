focusOnSearchField = ->
  $("#search_form_id").find("input").focus()

focusOnNewPageField = ->
  $("#add_page_id").find("input").focus()

focusOnTagInput = ->
  $("#tag_input_id").focus()

navigateToEditPage = ->
  window.location = $(".edit_link_cls").attr("href")

navigateToRecentPages = ->
  window.location = "/page/recent"

$ ->

  forwardSlashKeycode = 191
  tagInputKecode = 84
  navigateToEditPageKeycode = 69
  navigateToRecentPagesKeycode = 82
  newPageInputCode = 78
  recentPagesCharsTyped = []

  $("#index_ns_id #add_page_id input").focus()

  $("#index_ns_id #add_page_id input").keydown (e) ->
    if e.keyCode is forwardSlashKeycode
      e.preventDefault()
      focusOnSearchField()

  $("#page_ns_id").find(".rendered_markdown_cls").dblclick ->
    link = $("#page_ns_id").find(".edit_link_cls")[0]
    window.location = link.href

  $("#page_edit_ns_id").find("textarea").focus()

  $("#page_prepend_append_ns_id").find("textarea").focus()

  $("#page_edit_ns_id").find("textarea").keydown (e) ->
    if (e.keyCode == 13 && e.metaKey)
      e.preventDefault()
      e.stopPropagation()
      $("#page_edit_ns_id #editing_form_id").submit()
      return false

  $("table.tag_table_cls .name_cls").click ->
    $(this).hide()
    $(this).closest("td").find(".rename_tag_form_cls").show()

  $(document).bind "keydown.mdpg", (e) ->

    if e.target.tagName isnt "INPUT" and e.target.tagName isnt "TEXTAREA" and
    e.target.tagName isnt "SELECT"

      if e.keyCode is navigateToEditPageKeycode
        e.preventDefault()
        navigateToEditPage()

      if e.keyCode is navigateToRecentPagesKeycode
        e.preventDefault()
        navigateToRecentPages()

      if e.keyCode is forwardSlashKeycode
        e.preventDefault()
        focusOnSearchField()

      if e.keyCode is tagInputKecode
        e.preventDefault()
        focusOnTagInput()

      if e.keyCode is newPageInputCode
        e.preventDefault()
        focusOnNewPageField()
