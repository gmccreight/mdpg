# frozen_string_literal: true

require 'search_query_parser'

class Search
  private def initialize(user)
    @user_pages = UserPages.new(user)
    @user_page_tags = UserPageTags.new(user, nil)
    @search_parser = SearchQueryParser.new
  end

  def search(query, only: [])
    @search_parser.query = query

    keys = [:names, :tags, :texts]

    result = {}

    keys.each do |key|
      result[key] = if only.size.zero? || only.include?(key)
                      send('search_' + key.to_s)
                    else
                      []
                    end
    end

    result
  end

  private def search_strings
    @search_strings ||= @search_parser.search_strings
  end

  private def search_string
    search_strings[0]
  end

  private def search_names
    shared_search_for do |string|
      @user_pages.pages_with_names_containing_text(string)
    end
  end

  private def search_texts
    shared_search_for do |string|
      @user_pages.pages_with_text_containing_text(string)
    end
  end

  private def shared_search_for
    pages = nil

    search_strings.each do |string|
      found_pages = yield string
      found_page_ids = found_pages.map(&:id)

      pages = if pages.nil?
                found_pages
              else
                pages.select { |x| found_page_ids.include?(x.id) }
              end
    end

    pages_containing_one_of_the_tags(pages)
  end

  private def search_tags
    @user_page_tags.search(search_string)
  end

  private def pages_containing_one_of_the_tags(pages)
    return pages if @search_parser.tags.empty?

    pages.select do |page|
      !(ObjectTags.new(page).sorted_tag_names & @search_parser.tags).empty?
    end
  end
end
