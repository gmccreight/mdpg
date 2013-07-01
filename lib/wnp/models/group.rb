module Wnp::Models

  class Group < Base

    attr_accessor :name, :admins, :members

    private

      def validates?
      end

      def get_data_prefix
        "groupdata"
      end

  end

end
