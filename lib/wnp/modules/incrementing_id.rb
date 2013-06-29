module Wnp::Modules
  
  module IncrementingId

    def set_max_id(val)
      env.data.set("#{get_data_prefix()}-max-id", val)
    end

    def get_max_id
      env.data.get("#{get_data_prefix()}-max-id") || 0
    end

  end

end
