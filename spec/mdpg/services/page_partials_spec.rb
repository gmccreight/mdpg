require_relative "../../spec_helper"

describe PagePartials do

  describe "success" do

    it "should list fully opened and closed partials" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[:partial:coolname:start]] in it
        and also
        with [[:partial:coolname:end]]
      EOF
      partial = PagePartials.new
      partial.process(text)
      assert_equal ["coolname"], partial.list
    end

    it "should list fully opened and closed partials using uniq id syntax" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[:partial:coolname:start:axzegdababuwxnc]] in it
        and also
        with [[:partial:coolname:end:axzegdababuwxnc]]
      EOF
      partial = PagePartials.new
      partial.process(text)
      refute partial.had_error?
      assert_equal ["coolname"], partial.list
    end

  end

  describe "errors" do

    it "should not have any for well formatted partials" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[:partial:coolname:start]] in it
        and also
        with [[:partial:coolname:end]]
      EOF
      partial = PagePartials.new
      partial.process(text)
      refute partial.had_error?
    end

    it "should have an error for an un-closed partial" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[:partial:coolname:start]] in it
        and also
        wait... this is a bad partial with no end [[:partial:bad:start]]
        with [[:partial:coolname:end]]
      EOF
      partial = PagePartials.new
      partial.process(text)
      assert partial.had_error?
      assert_equal ["bad"], partial.partial_names_with_errors
    end

    it "should have an error for a partial with too many starts" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[:partial:coolname:start]] in it
        and also
        [[:partial:coolname:start]]
        with [[:partial:coolname:end]]
      EOF
      partial = PagePartials.new
      partial.process(text)
      assert partial.had_error?
      assert_equal ["coolname"], partial.partial_names_with_errors
    end

  end

end
