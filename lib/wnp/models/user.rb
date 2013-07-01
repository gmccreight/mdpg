module Wnp::Models

  class User < Base

    attr_accessor :name, :email

    private

      def validates?
      end

      def get_data_prefix
        "userdata"
      end

  end

end
