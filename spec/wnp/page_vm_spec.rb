require_relative "../spec_helper"

require "wnp/page_vm"

require "minitest/autorun"

describe Wnp::PageVm do

  before do
    user = Wnp::User.new(get_data(), 1)
    env = Wnp::Env.new(get_data(), user)
    page = Wnp::Page.new(get_data(), 1)
    @page_vm = Wnp::PageVm.new(env, page)
  end

  def user_1_has_tag?(tag)
    Wnp::UserTags.new(get_data(), 1).has_tag?(tag)
  end

  def page_1_has_tag?(tag)
    Wnp::PageTags.new(get_data(), 1).has_tag?(tag)
  end

  it "should be able to add a tag" do
    @page_vm.add_tag("good-stuff")
    assert user_1_has_tag?("good-stuff")
    assert page_1_has_tag?("good-stuff")
  end

  it "should be able to remove a tag" do
    @page_vm.add_tag("good-stuff")
    @page_vm.remove_tag("good-stuff")
    refute user_1_has_tag?("good-stuff")
    refute page_1_has_tag?("good-stuff")
  end

end
