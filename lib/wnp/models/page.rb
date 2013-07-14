module Wnp::Models

  class Page < Base

    attr_accessor :name, :text, :revision, :tag_ids

    def type_name
      "page"
    end

    def text_contains query
      text.include?(query)
    end

    def name_contains query
      name.include?(query)
    end

    def add_tag id
      self.tag_ids = ((tag_ids || []) + [id]).sort.uniq.sort
    end

    def remove_tag id
      self.tag_ids = ((tag_ids || []) - [id]).sort.uniq.sort
    end

    private

      def validates?
        Wnp::Token.new(name).validate
      end

      def get_data_prefix
        "pagedata"
      end

  end

end
