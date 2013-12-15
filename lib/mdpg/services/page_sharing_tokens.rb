class SharingTokenAlreadyExistsException < Exception
end

class PageSharingTokens < Struct.new(:page)

  def self.find_page_by_token token
    Page.find_by_index(:readonly_sharing_token, token) ||
      Page.find_by_index(:readwrite_sharing_token, token)
  end

  def rename_sharing_token type, new_token
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
