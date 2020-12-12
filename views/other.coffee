$ ->
  d = new Date()
  n = d.getTimezoneOffset()
  $("#page_prepend_append_ns_id form").append("<input name='timezone_offset_minutes' type='hidden' value='" + n + "'/>")
