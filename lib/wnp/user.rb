module Wnp

  class User < Struct.new(:data, :id)

    def load
      attrs = env.data.get("user_#{id}")
      self.page_ids_for_names = attrs[:page_ids_for_names]
    end

  end

end
