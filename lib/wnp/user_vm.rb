module Wnp

  class UserVm < Struct.new(:env, :user)

    def page_names
      user.get_page_ids().map{|x| page = Page.new(env, x); page.load; page.name}.sort
    end

  end

end
