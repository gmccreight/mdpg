# frozen_string_literal: true

class LabeledSectionIncludersInfo
  def initialize(page)
    @page = page
  end

  def run
    result = []
    transcluder = LabeledSectionTranscluder.new
    pages_that_link_to_or_include_this_page.each do |p|
      data = transcluder.internal_link_data(p.text)
      data.each do |datum|
        if datum[:page_id] == @page.id
          result << { page_id: p.id, section: datum[:section_id] }
        end
      end
    end
    result
  end

  def pages_that_link_to_or_include_this_page
    @page.referring_page_ids.map { |x| Page.find(x) }
  end
end
