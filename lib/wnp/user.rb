module Wnp

  class User < Struct.new(:data, :id)

    def load
      attrs = env.data.get("user_#{id}")
    end

    def add_page(id)

    end

    def get_pages

    end

  end

end
