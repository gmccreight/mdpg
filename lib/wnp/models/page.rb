module Wnp::Models

  class Page < Base

    attr_accessor :name, :text, :revision

    def text_contains query
      text.include?(query)
    end

    def name_contains query
      name.include?(query)
    end

    private

      def validates?
        Wnp::Token.new(name).validate
      end

      def get_data_prefix
        "userdata"
      end

  end

end
