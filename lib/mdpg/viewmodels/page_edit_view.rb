# frozen_string_literal: true

class PageEditView < Struct.new(:user, :page)
  def text_for_editing
    text = PageLinks.new(user)
      .internal_links_to_page_name_links_for_editing(page.text)
    text = LabeledSectionTranscluder.new
      .internal_links_to_user_facing_links(text)
    text
  end
end
