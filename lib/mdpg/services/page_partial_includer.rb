class PagePartialIncluder

  def initialize(user_pages)
    @user_pages = user_pages
  end

  def normalize_links_to_partials text
    text = text.gsub(
      /\[\[(#{Token::TOKEN_REGEX_STR}):(#{Token::TOKEN_REGEX_STR})\]\]/
    ) do
        page_name = $1
        partial_name = $2

        result = ""

        if page_name == "mdpgpage"
          result = "[[#{page_name}:#{partial_name}]]"
        else
          page = @user_pages.find_page_with_name(page_name)

          if page
            partials = PagePartials.new(page.text)
            partials.process
            identifier = partials.identifier_for(partial_name)

            if identifier
              result = "[[mdpgpage:#{page.id}:#{identifier}]]"
            end
          end
        end

        if result == ""
          result = "[[#{page_name}:#{partial_name}]]"
        end

        result
    end

    text

  end


end
