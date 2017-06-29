# frozen_string_literal: true
require_relative '../../spec_helper'

describe AdapterInputShortcutsNormalizer do
  describe 'labeled section creation' do
    it 'should follow the format' do
      text =     'vvwhat a testvvTesting Testingvvvv'
      expected = '[[#what-a-test]]Testing Testing[[#what-a-test]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(text)
    end
    it 'should allow capitalization at the start' do
      text =     'Vvwhat a testvvTesting Testingvvvv'
      expected = '[[#what-a-test]]Testing Testing[[#what-a-test]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(text)
    end
    it 'should shrink multiple spaces to single hyphen' do
      text =     'vvwhat a    testvvTesting Testingvvvv'
      expected = '[[#what-a-test]]Testing Testing[[#what-a-test]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(text)
    end
    it 'should do multiple' do
      text =     'vvtestvvTest1vvvv vvHi therevvtesting 2vvvv'
      expected = '[[#test]]Test1[[#test]] [[#hi-there]]testing 2[[#hi-there]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(text)
    end
  end
  describe 'page creation' do
    it 'should create a page' do
      text =     'nnnew Some crazy pagennnn'
      expected = '[[new-some-crazy-page]]'
      assert_equal expected, AdapterInputShortcutsNormalizer.new.normalize(text)
    end
  end
end
