class SharingTokenAlreadyExistsException < Exception
end

class PageSharingTokens < Struct.new(:page)

  TOKEN_TYPES = [:readonly, :readwrite]

  def self.find_page_by_token token
    TOKEN_TYPES.each do |type|
      if page = Page.find_by_index(:"#{type}_sharing_token", token)
        return [page, type]
      end
    end
    [nil, nil]
  end

  def rename_sharing_token type, new_token
    return :token_type_does_not_exist if ! TOKEN_TYPES.include?(type)
    if error = Token.new(new_token).validate
      return error
    else
      if Page.find_by_index(:"#{type}_sharing_token", new_token)
        raise SharingTokenAlreadyExistsException
      else
        page.send :"#{type}_sharing_token=", new_token
        page.save
      end
    end
    nil
  end

end
