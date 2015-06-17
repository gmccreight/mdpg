require_relative "../../spec_helper"

describe PagePartials do

  describe "adding unique identifiers to partial definitions" do

    it "should add missing identifier to partial definition without one" do
      text = (<<-EOF).gsub(/^ +/, '')
        start of the text

        [[#quote1:aaaxxxbbb]]
        here is a quote
        [[#quote1:aaaxxxbbb]]

        and then some additional content

        [[#quote2]]
        here is another quote
        [[#quote2]]

        end of text
      EOF
      partial = PagePartials.new(text)

      # Make the new identifier be a known value
      def partial.get_new_identifier
        "bbbegdababuwxxx"
      end

      new_text = partial.add_any_missing_identifiers

      expected_text = (<<-EOF).gsub(/^ +/, '')
        start of the text

        [[#quote1:aaaxxxbbb]]
        here is a quote
        [[#quote1:aaaxxxbbb]]

        and then some additional content

        [[#quote2:bbbegdababuwxxx]]
        here is another quote
        [[#quote2:bbbegdababuwxxx]]

        end of text
      EOF
      assert_equal expected_text, new_text
    end

  end

  describe "success" do

    it "should list fully opened and closed partials" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname]] in it
        and also
        with [[#coolname]]
      EOF
      partial = PagePartials.new(text)
      partial.process
      assert_equal ["coolname"], partial.list
    end

    it "should list fully opened and closed partials using uniq id syntax" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname:axzegdababuwxnc]] in it
        and also
        with [[#coolname:axzegdababuwxnc]]
      EOF
      partial = PagePartials.new(text)
      partial.process
      refute partial.had_error?
      assert_equal ["coolname"], partial.list
    end

    it "should give the uniq id for a name" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname:axzegdababuwxnc]] in it
        and also
        with [[#coolname:axzegdababuwxnc]]
      EOF
      partial = PagePartials.new(text)
      partial.process
      refute partial.had_error?
      assert_equal "axzegdababuwxnc", partial.identifier_for("coolname")
    end

    describe "text for a given partial" do

      it "should give the text for a partial" do
        text = (<<-EOF).gsub(/^ +/, '')
          here is some text
          with [[#coolname:axzegdababuwxnc]] in it
          and also
          with [[#coolname:axzegdababuwxnc]]
        EOF
        partial = PagePartials.new(text)
        partial.process
        result_with_no_newlines = partial.text_for("coolname").gsub(/\n/, " ")
        assert_equal "in it and also with", result_with_no_newlines
      end

      it "should not include other partial tags" do
        text = (<<-EOF).gsub(/^ +/, '')
          here is some text
          with [[#coolname:axzegdababuwxnc]] in it

          [[#otherone]]
          and also
          with [[#coolname:axzegdababuwxnc]]
          this is the end
          [[#otherone]]
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
        with [[#coolname]] in it
        and also
        with [[#coolname]]
      EOF
      partial = PagePartials.new(text)
      partial.process
      refute partial.had_error?
    end

    it "should have an error for an un-closed partial" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname]] in it
        and also
        wait... this is a bad partial with no end [[#bad]]
        with [[#coolname]]
      EOF
      partial = PagePartials.new(text)
      partial.process
      assert partial.had_error?
      assert_equal ["bad"], partial.partial_names_with_errors
    end

    it "should have an error for a partial with too many starts" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname]] in it
        and also
        [[#coolname]]
        with [[#coolname]]
      EOF
      partial = PagePartials.new(text)
      partial.process
      assert partial.had_error?
      assert_equal ["coolname"], partial.partial_names_with_errors
    end

  end

end
