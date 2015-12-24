require 'rand_string_generator'

class User < ModelBase
  ATTRS = [:name, :email, :salt, :hashed_password, :access_token, :page_ids,
           :recent_edited_page_ids, :recent_viewed_page_ids,
           :recent_created_page_ids, :clan_ids, :page_tags, :is_admin,
           :data_transitions]

  attr_accessor(*ATTRS)

  private def attr_defaults
    {
      access_token: proc { RandStringGenerator.rand_string_of_length(32) },
      salt: proc { RandStringGenerator.rand_string_of_length(32) },
      data_transitions: proc { [] }
    }
  end

  def self.authenticate(email, password)
    user = find_by_index :email, email
    return nil unless user
    return user if user.password_authenticates?(password)
    nil
  end

  def create(opts = {})
    @password = opts[:password]
    opts.delete :password
    super opts
  end

  attr_writer :password

  def save
    ensure_attr_defaults
    possibly_create_hashed_password
    super
  end

  def password_authenticates?(password)
    hashed_password == hash_this_password(password)
  end

  def add_page(page)
    add_associated_object page
    add_page_name_and_id_caching(page.name, page.id)
    UserRecentPages.new(self).add_to_recent_edited_pages_list(page)
    save
  end

  def add_page_name_and_id_caching(page_name, page_id)
    UserPageNameToIdMapping.new(id).add(page_name, page_id)
  end

  def remove_page_name_and_id_from_caching(page_name)
    UserPageNameToIdMapping.new(id).delete(page_name)
  end

  def remove_page(page)
    remove_associated_object page
    remove_page_name_and_id_from_caching(page.name)
    UserRecentPages.new(self).remove_from_all_recent_pages_lists(page)
    save
  end

  def add_clan(clan)
    add_associated_object clan
    save
  end

  def remove_clan(clan)
    remove_associated_object clan
    save
  end

  private def unique_id_indexes
    [:email, :access_token]
  end

  private def possibly_create_hashed_password
    self.hashed_password = hash_this_password(@password) if @password
  end

  private def hash_this_password(password)
    Digest::SHA1.hexdigest(password + salt)
  end
end
