require 'wnp/token'

module Wnp

  class PageTags < Struct.new(:data, :page_id)

    def add_tag(name)
      if error = Wnp::Token.new(name).validate
        return false
      end

      set_tags (get_tags + [name]).uniq.sort
    end

    def set_tags(tags)
      tags_hash = {}
      tags.each{|tag| tags_hash[tag] = true}
      data.set key, tags_hash
    end

    def get_tags
      get_tags_hash().keys
    end

    def has_tag?(tag)
      get_tags_hash().has_key?(tag)
    end

    private

      def get_tags_hash
        data.get(key) || {}
      end

      def key
        "pagetagsdata-#{page_id}-tags"
      end

  end

end
