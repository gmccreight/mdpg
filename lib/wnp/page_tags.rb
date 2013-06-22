require 'wnp/token'

module Wnp

  class PageTags < Struct.new(:data, :page_id)

    def add_tag(name)
      if error = Wnp::Token.new(name).validate
        return false
      end

      set_tags get_tags + [name]
    end

    def remove_tag(name)
      set_tags get_tags - [name]
    end

    def set_tags(tags)
      data.set key, Hash[tags.map {|x| [x,true]}]
    end

    def get_tags
      get_tags_hash().keys.sort
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
