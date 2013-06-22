require_relative "../spec_helper"

require "wnp/page_tags"

require "minitest/autorun"

describe Wnp::PageTags do

  before do
    @page_tags = Wnp::PageTags.new(get_data(), 1)
  end

  it "should be able to add a page tag" do
    @page_tags.add_tag "cool-house"
    assert @page_tags.has_tag?("cool-house")
  end

  it "should be not add the same tag more than once" do
    @page_tags.add_tag "cool-house"
    @page_tags.add_tag "cool-house"
    assert_equal ["cool-house"], @page_tags.get_tags()
  end

end
