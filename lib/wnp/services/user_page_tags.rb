require 'wnp/token'

module Wnp::Services

  class UserPageTags < Struct.new(:data, :user_id)

    def add_tag tag_name, page_id
      if error = Wnp::Token.new(tag_name).validate
        return false
      end

      h = get_tags_hash()
      if ! h.has_key?(tag_name)
        h[tag_name] = {}
      end
      h[tag_name][page_id.to_s] = true
      data.set key, h
    end

    def remove_tag tag_name, page_id
      if error = Wnp::Token.new(tag_name).validate
        return false
      end

      h = get_tags_hash()
      if ! h.has_key?(tag_name)
        return
      else
        if h[tag_name].has_key?(page_id.to_s)
          h[tag_name].delete(page_id.to_s)
          if h[tag_name].keys.size == 0
            h.delete(tag_name)
          end
        end
      end

      data.set key, h

    end

    def search query
      get_tags.select{|tag| tag.include?(query)}
    end

    def get_tags
      get_tags_hash().keys.sort
    end

    def has_tag? tag
      get_tags_hash().has_key?(tag)
    end

    def tag_count tag
      h = get_tags_hash()
      return 0 if ! h.has_key?(tag)
      return h[tag].keys.size
    end

    private

      def get_tags_hash
        h = data.get(key) || {}
        h.default = {}
        h
      end

      def key
        "usertagsdata-#{user_id}-tags"
      end

  end

end
