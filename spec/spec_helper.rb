def get_data
  @data ||= Wnp::Data.new :memory
end

def create_page id, data
  get_data().set "pagedata-#{id}-0", data
end
