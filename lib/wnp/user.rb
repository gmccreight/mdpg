module Wnp

  class User < Struct.new(:data, :id)

    def load
      attrs = env.data.get("userdata-#{id}")
    end

    def add_page id
      set_page_ids (get_page_ids + [id]).uniq.sort
    end

    def remove_page id
      set_page_ids (get_page_ids - [id]).uniq.sort
    end

    def set_page_ids page_ids
      data.set "userdata-#{id}-page-ids", page_ids
    end

    def get_page_ids
      data.get("userdata-#{id}-page-ids") || []
    end

  end

end
