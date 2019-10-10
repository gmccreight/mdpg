# frozen_string_literal: true

# On a mobile device, it's a pain to switch keyboards.  This adapter allows
# you to use crazy shortcuts in input.  It translates those shortcuts to the
# expected long-form format before the page content is saved.

class AdapterInputShortcutsNormalizer
  def normalize(input)
    result = normalize_labeled_section_creation(input)
    result = normalize_new_page_creation(result)
    result = normalize_spaced_repetition_automatic_back_creation(result)
    result = normalize_spaced_repetition_card_front_back(result)
    result
  end

  # 'vv what a test vv Testing Testing'
  # becomes
  # '[[#what-a-test]]Testing Testing[[#what-a-test]]'
  #
  # or an explicit end
  #
  # 'vv what a test vv Testing Testing vvvv is good'
  # becomes
  # '[[#what-a-test]]Testing Testing[[#what-a-test]] is good'
  def normalize_labeled_section_creation(input)
    input.gsub(/vv ([^ ].*?[^ ]) vv (.*?)\s?(vvvv|$)/i) do
      name = Regexp.last_match(1)
      text = Regexp.last_match(2)
      text = text.strip
      token = normalize_name_into_token(name)
      "[[##{token}]]#{text}[[##{token}]]"
    end
  end

  # 'nnnew some page nnnn'
  # becomes
  # '[[new-some-page]]'
  def normalize_new_page_creation(input)
    input.gsub(/nnnew (.*?) nnnn/i) do
      token = normalize_name_into_token(Regexp.last_match(1))
      "[[new-#{token}]]"
    end
  end

  # 'mutable xx default yy values are xx persistent yy'
  # becomes
  # 'sr:: mutable **default** values are **persistent** ::rs'
  def normalize_spaced_repetition_automatic_back_creation(input)
    result = []
    input.lines.each do |line|
      if line =~ /(^| )xx .+ yy/
        transformed = line.gsub(/(^| )xx (.*?) yy/) do
          before = Regexp.last_match(1)
          text = Regexp.last_match(2)
          "#{before}**#{text}**"
        end
        result << "sr:: #{transformed.chomp} ::rs"
        if transformed.chomp != transformed
          result << "\n"
        end
      else
        result << line
      end
    end
    result = result.join
  end

  # typed on mobile keyboard:
  # 'what are is the name of X? ssrrr some answer'
  #
  # and spoken, with the words "back separator" as the split string:
  # 'what are is the name of X? back separator some answer'
  #
  # becomes
  # 'sr:: what are is the name of X? || some answer ::rs'
  def normalize_spaced_repetition_card_front_back(input)
    result = []
    input.lines.each do |line|
      if line =~ / (ssrrr|back separator) /
        transformed = line.sub(/ (ssrrr|back separator) /i, ' || ')
        result << "sr:: #{transformed.chomp} ::rs"
        if transformed.chomp != transformed
          result << "\n"
        end
      else
        result << line
      end
    end
    result = result.join
  end

  def normalize_name_into_token(name)
    result = name.strip
    result = result.downcase
    result = result.gsub(/ +/, ' ')
    result = result.tr(' ', '-')
    result
  end
end
