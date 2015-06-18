class SharingTokenAlreadyExistsException < Exception
end

class PageSharingTokens < Struct.new(:page)

  TOKEN_TYPES = [:readonly, :readwrite]

  def self.find_page_by_token token
    TOKEN_TYPES.each do |type|
      if page = Page.find_by_index(:"#{type}_sharing_token", token)
        if self._get_sharing_token_of_type_is_actived page, type
          return [page, type]
        end
      end
    end
    [nil, nil]
  end

  def self._get_sharing_token_of_type_is_actived page, type
    val = page.send :"#{type}_sharing_token_activated"
    !! val
  end

  def rename_sharing_token type, new_token
    return :token_type_does_not_exist if ! TOKEN_TYPES.include?(type)
    if error = Token.new(new_token).validate
      return error
    else
      found_page, _token_type = self.class.find_page_by_token(new_token)
      if found_page
        if found_page.id != page.id
          raise SharingTokenAlreadyExistsException
        end
      end
      page.send :"#{type}_sharing_token=", new_token
      page.save
    end
    nil
  end

  def activate_sharing_token type
    _set_activation type, true
  end

  def deactivate_sharing_token type
    _set_activation type, false
  end

  private def _set_activation type, value
    return :token_type_does_not_exist if ! TOKEN_TYPES.include?(type)
    page.send :"#{type}_sharing_token_activated=", value
    page.save
    true
  end

end
