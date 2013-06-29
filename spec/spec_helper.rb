def get_data
  @data ||= Wnp::Data.new :memory
end

def create_user id, data = {}
  get_data().set "userdata-#{id}", data
  Wnp::User.new get_data(), id
end

def create_page id, data = {}
  get_data().set "pagedata-#{id}-0", data
  Wnp::Page.new get_data(), id
end

def create_group id, data = {}
  get_data().set "groupdata-#{id}", data
  Wnp::Group.new get_data(), id
end
