module Wnp::Models

  class Group < Base

    attr_accessor :name, :admins, :members

    private

      def validates?
      end

  end

end
