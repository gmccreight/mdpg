module Wnp::Models

  class Page < Base

    attr_accessor :name, :text, :revision, :tag_ids

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
        errors = Wnp::Token.new(name).validate
        return ! errors
      end

  end

end
