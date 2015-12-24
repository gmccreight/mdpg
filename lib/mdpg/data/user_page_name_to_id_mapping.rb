class UserPageNameToIdMapping

  def initialize(user_id)
    @user_id = user_id
    @data_store = $data_store
    @data = nil
  end

  def add(page_name, page_id)
    data = get
    data[page_name] = page_id
    set(data)
  end

  def delete(page_name)
    data = get
    data.delete(page_name)
    set(data)
  end

  def get_id_for_page_name(page_name)
    get[page_name]
  end

  def get
    @data ||= (@data_store.get(data_key) || {})
  end

  def set(data)
    @data_store.set(data_key, data)
    @data = nil
  end

  def data_key
    "userpagenametoiddata-#{@user_id}"
  end

end
