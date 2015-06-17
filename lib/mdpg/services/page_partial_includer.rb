class PagePartialIncluder

  def replace_links_to_partials_with_actual_content text
    text.gsub(
      /\[\[mdpgpage:(\d+):(#{Token::TOKEN_REGEX_STR})\]\]/
    ) do
        page_id = $1.to_i
        partial_identifier = $2

        page = Page.find(page_id)

        partial = PagePartials.new(Page.find(page_id).text)
        partial.process

        "[[#{page.name}##{partial_identifier}:start]]

        #{partial.text_for(partial_identifier)}

        [[#{page.name}##{partial_identifier}:end]]".gsub(/^[ ]+/, '')
      end
  end

  def normalize_links_to_partials text, user_pages
    text = text.gsub(
      /\[\[(#{Token::TOKEN_REGEX_STR})#(#{Token::TOKEN_REGEX_STR})\]\]/
    ) do
        page_name = $1
        partial_name = $2

        result = ""

        if page_name == "mdpgpage"
          result = "[[#{page_name}:#{partial_name}]]"
        else
          page = user_pages.find_page_with_name(page_name)

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
          result = "[[#{page_name}##{partial_name}]]"
        end

        result
    end

    text

  end


end
