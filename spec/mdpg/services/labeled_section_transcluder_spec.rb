# frozen_string_literal: true
require_relative '../../spec_helper'

describe LabeledSectionTranscluder do
  before do
    $data_store = memory_datastore
  end

  it 'should be able to transclude labeled section from other page' do
    user = User.create
    user_pages = UserPages.new user

    ident = 'abababababababab'

    other_text = <<-EOF.gsub(/^ +/, '')
      something that we're talking about
      with [[#important-idea:#{ident}]]
      John James said: "this is an important idea"
      [[#important-idea:#{ident}]]
    EOF
    other_page = user_pages.create_page name: 'other-page', text: other_text

    this_text = <<-EOF.gsub(/^ +/, '')
      From the other page:

      [[other-page#important-idea]]

      is what it was talking about
    EOF

    this_page = user_pages.create_page name: 'this-page', text: this_text

    expected_text = <<-EOF.gsub(/^ +/, '')
      From the other page:

      [[mdpgpage:#{other_page.id}:#{ident}]]

      is what it was talking about
    EOF

    assert_equal expected_text, this_page.text
  end

  it 'should be able to transclude with short option' do
    user = User.create
    user_pages = UserPages.new user

    ident = 'abababababababab'

    other_text = <<-EOF.gsub(/^ +/, '')
      something that we're talking about
      with [[#important-idea:#{ident}]]
      John James said: "this is an important idea"
      [[#important-idea:#{ident}]]
    EOF
    other_page = user_pages.create_page name: 'other-page', text: other_text

    this_text = <<-EOF.gsub(/^ +/, '')
      From the other page:

      [[other-page#important-idea:short]]

      is what it was talking about
    EOF

    this_page = user_pages.create_page name: 'this-page', text: this_text

    expected_text = <<-EOF.gsub(/^ +/, '')
      From the other page:

      [[mdpgpage:#{other_page.id}:#{ident}:short]]

      is what it was talking about
    EOF

    assert_equal expected_text, this_page.text
  end
end
