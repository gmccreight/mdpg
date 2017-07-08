# frozen_string_literal: true

# On a mobile device, it's a pain to switch keyboards.  This adapter allows
# you to use crazy shortcuts in input.  It translates those shortcuts to the
# expected long-form format before the page content is saved.

class AdapterInputShortcutsNormalizer
  def normalize(input)
    result = normalize_labeled_section_creation(input)
    result = normalize_new_page_creation(result)
    result
  end

  # 'vv what a test vv Testing Testing vvvv'
  # becomes
  # '[[#what-a-test]]Testing Testing[[#what-a-test]]'
  def normalize_labeled_section_creation(input)
    input.gsub(/vv ([^ ].*?[^ ]) vv (.*?)vvvv/i) do
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

  def normalize_name_into_token(name)
    result = name.strip
    result = result.downcase
    result = result.gsub(/ +/, ' ')
    result = result.tr(' ', '-')
    result
  end
end
