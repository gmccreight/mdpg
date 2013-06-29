require 'wnp/token'

module Wnp

  class PageTags < Struct.new(:data, :page_id)

    def add_tag(name)
      if error = Wnp::Token.new(name).validate
        return false
      end
      
      return false if has_tag?(name)

      set_tags get_tags + [name]
      set_page_ids_associated_with_tag(name, (get_page_ids_associated_with_tag(name) + [page_id]).uniq)
    end

    def remove_tag(name)
      if error = Wnp::Token.new(name).validate
        return false
      end

      return false if ! has_tag?(name)

      set_tags get_tags - [name]
      set_page_ids_associated_with_tag(name, get_page_ids_associated_with_tag(name) - [page_id])
    end

    def set_tags(tags)
      data.set data_key, Hash[tags.map {|x| [x,true]}]
    end

    def get_page_ids_associated_with_tag(tag_name)
      data.get("pagetagsdata-#{tag_name}-page-ids") || []
    end

    def set_page_ids_associated_with_tag(tag_name, page_ids)
      data.set "pagetagsdata-#{tag_name}-page-ids", page_ids
    end

    def get_tags
      get_tags_hash().keys.sort
    end

    def has_tag?(tag)
      get_tags_hash().has_key?(tag)
    end

    private

      def get_tags_hash
        data.get(data_key) || {}
      end

      def data_key
        "pagetagsdata-#{page_id}-tags"
      end

  end

end
