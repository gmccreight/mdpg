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
  describe 'spaced repetition' do
    it 'should replace shorthand with longer-hand' do
      t = "mutable xx default yy values are xx persistent yy"
      expected = "sr:: mutable **default** values are **persistent** ::rs"
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should replace it right at the start of the line' do
      t = "xx mutable default yy values are xx persistent yy"
      expected = "sr:: **mutable default** values are **persistent** ::rs"
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should be ok with other newlines' do
      t = "mutable xx default yy values are xx persistent yy\n\ntesting"
      expected = "sr:: mutable **default** values are **persistent** ::rs\n\ntesting"
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should with with front and back both defined' do
      t = "what are is the name of X? ssrrr some answer"
      expected = "sr:: what are is the name of X? || some answer ::rs"
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should with with front and back both defined - spoken' do
      t = "what are is the name of X? back separator some answer"
      expected = "sr:: what are is the name of X? || some answer ::rs"
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
    it 'should with with front and back both defined - spoken - with multiple lines' do
      t = "what are is the name of X? back separator some answer\n\ntesting"
      expected = "sr:: what are is the name of X? || some answer ::rs\n\ntesting"
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(t)
    end
  end
end
