module Wnp::Models

  class User < Base

    attr_accessor :name, :email

    private

      def validates?
      end

      def get_data_prefix
        "userdata"
      end

      def data_key
        "#{get_data_prefix}-#{id}"
      end

  end

end
