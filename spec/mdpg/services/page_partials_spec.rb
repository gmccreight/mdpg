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
      partial = PagePartials.new(text)
      partial.process
      assert_equal ["coolname"], partial.list
    end

    it "should list fully opened and closed partials using uniq id syntax" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[:partial:coolname:start:axzegdababuwxnc]] in it
        and also
        with [[:partial:coolname:end:axzegdababuwxnc]]
      EOF
      partial = PagePartials.new(text)
      partial.process
      refute partial.had_error?
      assert_equal ["coolname"], partial.list
    end

    describe "text for a given partial" do

      it "should give the text for a partial" do
        text = (<<-EOF).gsub(/^ +/, '')
          here is some text
          with [[:partial:coolname:start:axzegdababuwxnc]] in it
          and also
          with [[:partial:coolname:end:axzegdababuwxnc]]
        EOF
        partial = PagePartials.new(text)
        partial.process
        result_with_no_newlines = partial.text_for("coolname").gsub(/\n/, " ")
        assert_equal "in it and also with", result_with_no_newlines
      end

      it "should not include other partial tags" do
        text = (<<-EOF).gsub(/^ +/, '')
          here is some text
          with [[:partial:coolname:start:axzegdababuwxnc]] in it

          [[:partial:otherone:start]]
          and also
          with [[:partial:coolname:end:axzegdababuwxnc]]
          this is the end
          [[:partial:otherone:end]]
        EOF
        partial = PagePartials.new(text)
        partial.process
        result_with_no_newlines = partial.text_for("coolname").gsub(/\n/, " ")
        assert_equal "in it and also with", result_with_no_newlines
      end

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
      partial = PagePartials.new(text)
      partial.process
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
      partial = PagePartials.new(text)
      partial.process
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
      partial = PagePartials.new(text)
      partial.process
      assert partial.had_error?
      assert_equal ["coolname"], partial.partial_names_with_errors
    end

  end

end
