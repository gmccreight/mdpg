require_relative "../../spec_helper"

describe LabeledSections do

  describe "adding unique identifiers to section definitions" do

    it "should add missing identifier to section definition without one" do
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
      section = LabeledSections.new(text)

      # Make the new identifier be a known value
      def section.get_new_identifier
        "bbbegdababuwxxx"
      end

      new_text = section.add_any_missing_identifiers

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

    it "should list fully opened and closed sections" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname]] in it
        and also
        with [[#coolname]]
      EOF
      section = LabeledSections.new(text)
      section.process
      assert_equal ["coolname"], section.list
    end

    it "should list fully opened and closed sections using uniq id syntax" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname:axzegdababuwxnc]] in it
        and also
        with [[#coolname:axzegdababuwxnc]]
      EOF
      section = LabeledSections.new(text)
      section.process
      refute section.had_error?
      assert_equal ["coolname"], section.list
    end

    it "should give the uniq id for a name" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname:axzegdababuwxnc]] in it
        and also
        with [[#coolname:axzegdababuwxnc]]
      EOF
      section = LabeledSections.new(text)
      section.process
      refute section.had_error?
      assert_equal "axzegdababuwxnc", section.identifier_for("coolname")
    end

    describe "text for a given section" do

      it "should give the text for a section" do
        text = (<<-EOF).gsub(/^ +/, '')
          here is some text
          with [[#coolname:axzegdababuwxnc]] in it
          and also
          with [[#coolname:axzegdababuwxnc]]
        EOF
        section = LabeledSections.new(text)
        section.process
        result_with_no_newlines = section.text_for("coolname").gsub(/\n/, " ")
        assert_equal "in it and also with", result_with_no_newlines
      end

      it "should not include other section tags" do
        text = (<<-EOF).gsub(/^ +/, '')
          here is some text
          with [[#coolname:axzegdababuwxnc]] in it

          [[#otherone]]
          and also
          with [[#coolname:axzegdababuwxnc]]
          this is the end
          [[#otherone]]
        EOF
        section = LabeledSections.new(text)
        section.process
        result_with_no_newlines = section.text_for("coolname").gsub(/\n/, " ")
        assert_equal "in it and also with", result_with_no_newlines
      end

    end

  end

  describe "errors" do

    it "should not have any for well formatted sections" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname]] in it
        and also
        with [[#coolname]]
      EOF
      section = LabeledSections.new(text)
      section.process
      refute section.had_error?
    end

    it "should have an error for an un-closed section" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname]] in it
        and also
        wait... this is a bad section with no end [[#bad]]
        with [[#coolname]]
      EOF
      section = LabeledSections.new(text)
      section.process
      assert section.had_error?
      assert_equal ["bad"], section.section_names_with_errors
    end

    it "should have an error for a section with too many starts" do
      text = (<<-EOF).gsub(/^ +/, '')
        here is some text
        with [[#coolname]] in it
        and also
        [[#coolname]]
        with [[#coolname]]
      EOF
      section = LabeledSections.new(text)
      section.process
      assert section.had_error?
      assert_equal ["coolname"], section.section_names_with_errors
    end

  end

end
