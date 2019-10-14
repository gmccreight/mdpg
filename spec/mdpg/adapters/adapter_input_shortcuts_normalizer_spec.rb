# frozen_string_literal: true
require_relative '../../spec_helper'

describe AdapterInputShortcutsNormalizer do
  describe 'labeled section creation' do
    it 'should follow the format' do
      t = 'vv what a test vv Testing Testing'
      expected = '[[#what-a-test]]Testing Testing[[#what-a-test]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should allow capitalization at the start' do
      t = 'Vv what a test vv Testing Testing'
      expected = '[[#what-a-test]]Testing Testing[[#what-a-test]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should shrink multiple spaces to single hyphen' do
      t = 'vv what a    test vv Testing Testing'
      expected = '[[#what-a-test]]Testing Testing[[#what-a-test]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should break on a newline' do
      t = "vv what a test vv Testing Testing \n\nother"
      expected = "[[#what-a-test]]Testing Testing[[#what-a-test]]\n\nother"
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should do multiple' do
      t = 'vv test vv Test1 vvvv vv Hi there vv testing 2 vvvv'
      expected = '[[#test]]Test1[[#test]] [[#hi-there]]testing 2[[#hi-there]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
  end
  describe 'page creation' do
    it 'should create a page' do
      t = 'nnnew Some crazy page nnnn'
      expected = '[[new-some-crazy-page]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
  end
  describe 'replace with UUID' do
    it 'should replace "make the id." with UUID and colon' do
      t = 'testing foo bar Make the ID. Hello'
      transformed = AdapterInputShortcutsNormalizer.new.normalize(t)
      guid_without_colon = %r{[0-9a-z]{10}}
      assert transformed =~ guid_without_colon
      transformed = transformed.sub(guid_without_colon, '')
      assert_equal "testing foo bar : Hello", transformed
    end
    it 'should replace mmmiii with UUID and colon' do
      t = 'testing foo bar mmmiii Hello'
      transformed = AdapterInputShortcutsNormalizer.new.normalize(t)
      guid_without_colon = %r{[0-9a-z]{10}}
      assert transformed =~ guid_without_colon
      transformed = transformed.sub(guid_without_colon, '')
      assert_equal "testing foo bar : Hello", transformed
    end
  end

  def expect_sr_match(raw, expected_core, prefix: '', suffix: '')
    expected = prefix + "sr:: #{expected_core} ::rs" + suffix
    transformed = AdapterInputShortcutsNormalizer.new.normalize(raw)
    guid_with_colon = %r{[0-9a-z]{10}:}
    assert transformed =~ guid_with_colon
    transformed = transformed.sub(guid_with_colon, '')
    transformed = transformed.sub(/sr::  /, 'sr:: ')
    assert_equal expected, transformed
  end

  describe 'spaced repetition' do
    it 'should replace shorthand with longer-hand' do
      t = "mutable xx default yy values are xx persistent yy"
      expected_core = "mutable **default** values are **persistent**"
      expect_sr_match(t, expected_core)
    end
    it 'should replace it right at the start of the line' do
      t = "xx mutable default yy values are xx persistent yy"
      expected_core = "**mutable default** values are **persistent**"
      expect_sr_match(t, expected_core)
    end
    it 'should be ok with other newlines' do
      t = "mutable xx default yy values are xx persistent yy\n\ntesting"
      expected_core = "mutable **default** values are **persistent**"
      expect_sr_match(t, expected_core, suffix: "\n\ntesting")
    end
    it 'should with with front and back both defined' do
      t = "what are is the name of X? ssrrr some answer"
      expected_core = "what are is the name of X? || some answer"
      expect_sr_match(t, expected_core)
    end
    it 'should with with front and back both defined - spoken' do
      t = "what are is the name of X? Back separator some answer"
      expected_core = "what are is the name of X? || some answer"
      expect_sr_match(t, expected_core)
    end
    it 'should with with front and back both defined - spoken - with multiple lines' do
      t = "what are is the name of X? back separator some answer\n\ntesting"
      expected_core = "what are is the name of X? || some answer"
      expect_sr_match(t, expected_core, suffix: "\n\ntesting")
    end
  end
end
