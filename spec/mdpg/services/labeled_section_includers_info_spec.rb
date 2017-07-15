# frozen_string_literal: true
require_relative '../../spec_helper'

describe LabeledSectionIncludersInfo do
  before do
    $data_store = memory_datastore
  end

  it 'gives information about who includes sections from this page' do
    user = User.create
    user_pages = UserPages.new user

    id_1 = 'aaaaaaaaaaaaaaaa'
    id_2 = 'bbbbbbbbbbbbbbbb'

    target_text = <<-EOF.gsub(/^ +/, '')
      something that we're talking about
      with [[#important-idea:#{id_1}]]
      John James said: "this is an important idea"
      [[#important-idea:#{id_1}]]
      [[#fleeting-idea:#{id_2}]]
      Flea said: "this is a fleeting idea"
      [[#fleeting-idea:#{id_2}]]
    EOF
    target_page = user_pages.create_page name: 'target-page',
      text: target_text

    other_ident = 'cccccccccccccccc'
    other_text = <<-EOF.gsub(/^ +/, '')
      yo [[#other-thing:#{other_ident}]]
      H said: "this is some other thing"
      [[#other-thing:#{other_ident}]]
    EOF
    user_pages.create_page name: 'other-page', text: other_text

    i_text_1 = <<-EOF.gsub(/^ +/, '')
      From the main page:

      [[target-page#important-idea:short]]

      and the other thing

      [[other-page#other-thing]]

      is what it was talking about
    EOF
    i_page_1 = user_pages.create_page name: 'inc-page-1', text: i_text_1

    i_text_2 = <<-EOF.gsub(/^ +/, '')
      This was an important idea:

      [[target-page#important-idea:short]]

      [[target-page#fleeting-idea:short]]

      for sure
    EOF
    i_page_2 = user_pages.create_page name: 'inc-page-2', text: i_text_2

    target_page = Page.find(target_page.id)
    includers_info = LabeledSectionIncludersInfo.new(target_page).run
    expected = [
      { page_id: i_page_1.id, section: id_1 },
      { page_id: i_page_2.id, section: id_1 },
      { page_id: i_page_2.id, section: id_2 }
    ]
    assert_equal expected, includers_info
  end
end
