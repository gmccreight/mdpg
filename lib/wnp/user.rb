module Wnp

  class User < Struct.new(:data, :id)

    def load
      attrs = env.data.get("user_#{id}")
    end

    def add_page(id)
      page_ids = get_page_ids() + [id]
      set_page_ids(page_ids.uniq.sort)
    end

    def set_page_ids(page_ids)
      data.set("user-#{id}-page-ids", page_ids)
    end

    def get_page_ids
      data.get("user-#{id}-page-ids") || []
    end

  end

end
