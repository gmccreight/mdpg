# frozen_string_literal: true

module AppSection
  class PageTag
    def initialize(app, user = nil)
      @app = app
      @current_user = user
    end

    attr_reader :current_user

    def all_for_page(page)
      object_tags = ObjectTags.new(page)
      user_page_tags = UserPageTags.new(current_user, page)
      sorted_tag_names = object_tags.sorted_tag_names
      results = sorted_tag_names.map do |tagname|
        {
          text: tagname,
          has_tag_page: user_page_tags.tag_has_associated_page?(tagname),
          associated: user_page_tags.sorted_associated_tags(tagname)
        }
      end
      results.to_json
    end

    def suggestions(page, tag_typed)
      tags = PageView.new(current_user, page, nil)
                     .tag_suggestions_for(tag_typed)
      { tags: tags }.to_json
    end

    def add(page, tag_name)
      page_view = PageView.new(current_user, page, nil)
      if page_view.add_tag(tag_name)
        UserPages.new(current_user).page_was_updated page
        return { success: "added tag #{tag_name}" }.to_json
      else
        return { error: "could not add the tag #{tag_name}" }.to_json
      end
    end

    def delete(page, tag_name)
      page_view = PageView.new(current_user, page, nil)
      if page_view.remove_tag(tag_name)
        UserPages.new(current_user).page_was_updated page
        return { success: "removed tag #{tag_name}" }.to_json
      else
        return { error: "the tag #{tag_name} could not be deleted" }.to_json
      end
    end
  end
end
