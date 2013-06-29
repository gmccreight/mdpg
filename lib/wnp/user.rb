module Wnp

  class User < Struct.new(:data, :id)

    def load
      attrs = env.data.get("userdata-#{id}")
    end

    def add_page id
      set_page_ids (get_page_ids + [id]).uniq.sort
    end

    def set_page_ids page_ids
      data.set "userdata-#{id}-page-ids", page_ids
    end

    def get_page_ids
      data.get("userdata-#{id}-page-ids") || []
    end

    def add_group id
      set_group_ids (get_group_ids + [id]).uniq.sort
    end

    def set_group_ids ids
      data.set "userdata-#{id}-group-ids", ids
    end

    def get_group_ids
      data.get("userdata-#{id}-group-ids") || []
    end

  end

end
