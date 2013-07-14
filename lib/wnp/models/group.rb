module Wnp::Models

  class Group < Base

    attr_accessor :name, :admins, :members

    private

      def validates?
      end

      #[tag:refactor:gem] could be derived from the class name
      def get_data_prefix
        "groupdata"
      end

  end

end
