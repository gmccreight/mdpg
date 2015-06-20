require File.expand_path '../sinatra_helper.rb', __FILE__

describe 'tag' do
  before do
    $data_store = memory_datastore

    @user = User.create name: 'Jordan',
      email: 'jordan@example.com', password: 'cool'
    UserPages.new @user
    @page = UserPages.new(@user).create_page name: 'a-good-page',
      text: 'I wish I had something *interesting* to say!'
  end

  def add_tag(user, page_name, tag_name)
    post "/p/#{page_name}/tags", { text: tag_name }.to_json,
      authenticated_session(user)
  end

  def rename_tag(user, original_name, new_name)
    post "/t/#{original_name}/rename", { new_name: new_name },
      authenticated_session(user)
  end

  describe 'renaming' do
    before do
      add_tag @user, 'a-good-page', 'new-1'

      @other_page = UserPages.new(@user).create_page name: 'other-page',
        text: 'nothing really'
      add_tag @user, 'other-page', 'new-1'
    end

    it 'should rename the tag if no other with name exists' do
      rename_tag @user, 'new-1', 'new-2'
      follow_redirect_with_authenticated_user!(@user.reload)
      assert_equal ['new-2'],
        UserPageTags.new(@user, @page.reload).get_tag_names
      assert_equal ['new-2'],
        UserPageTags.new(@user, @other_page.reload).get_tag_names
    end
  end
end
