require_relative '../../spec_helper'

describe Clan do

  before do
    $data_store = get_memory_datastore
  end

  def create_clan_with_name name
    Clan.create name:name
  end

  describe 'creation' do

    it 'should make a clan' do
      clan = create_clan_with_name 'good'
      assert_equal clan.name, 'good'
    end

  end

end
