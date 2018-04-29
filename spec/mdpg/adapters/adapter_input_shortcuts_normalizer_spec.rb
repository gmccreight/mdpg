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
end
