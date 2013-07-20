if ENV["perf"]

  require_relative "../spec_helper"

  describe "Perfomance" do

    before do
      $data_store = get_memory_datastore()
    end

    it "should be fast" do
      require 'ruby-prof'

      RubyProf.start

      user = Wnp::Models::User.create name:"John", email:"good@email.com", password:"cool"
      assert_equal 1, user.id
      assert_equal "good@email.com", user.email

      result = RubyProf.stop
      printer = RubyProf::FlatPrinter.new(result)
      printer.print(STDOUT)
    end

  end

end
