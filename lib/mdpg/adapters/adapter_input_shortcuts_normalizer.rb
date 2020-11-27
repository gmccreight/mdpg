# frozen_string_literal: true

# On a mobile device, it's a pain to switch keyboards.  This adapter allows
# you to use crazy shortcuts in input.  It translates those shortcuts to the
# expected long-form format before the page content is saved.

class AdapterInputShortcutsNormalizer
  def normalize(input, user_pages)
    result = input
    result = add_labeled_section_transclusion_syntax(result, user_pages)
    result = normalize_labeled_section_creation(result)
    result = normalize_new_page_creation(result)
    result = normalize_spaced_repetition_automatic_back_creation(result)
    result = normalize_spaced_repetition_card_front_back(result)
    result = replace_with_uuids(result)
    result
  end

  # page#section
  # becomes
  # [[page#section:short]]
  # if the user has pages with sections that make that work
  def add_labeled_section_transclusion_syntax(input, user_pages)
    result = []
    min = Token::TOKEN_MIN_LENGTH
    max = Token::TOKEN_MAX_LENGTH
    input.lines.each do |line|
      transformed = line.gsub(/(?<!\w)([a-z0-9-]{#{min},#{max}})#([a-z0-9-]{#{min},#{max}})/) do
        page_name = Regexp.last_match(1)
        section = Regexp.last_match(2)
        page = user_pages.find_page_with_name(page_name)
        if page
          if page.text =~ /\[\[##{section}:/
            "[[#{page_name}##{section}:short]]"
          else
            "#{page_name}##{section}"
          end
        else
          "#{page_name}##{section}"
        end
      end
      result << transformed
    end
    result = result.join
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

  def make_sr_chunk(transformed)
    "sr:: #{guid}: #{transformed.chomp} ::rs"
  end

  # 'mutable xx default yy values are xx persistent yy'
  # becomes
  # 'sr:: 2d931510xz: mutable **default** values are **persistent** ::rs'
  def normalize_spaced_repetition_automatic_back_creation(input)
    result = []
    input.lines.each do |line|
      if line =~ /(^| )xx .+ yy/
        transformed = line.gsub(/(^| )xx (.*?) yy/) do
          before = Regexp.last_match(1)
          text = Regexp.last_match(2)
          "#{before}**#{text}**"
        end
        result << make_sr_chunk(transformed)
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
  # 'sr:: 2d931510xz: what are is the name of X? || some answer ::rs'
  def normalize_spaced_repetition_card_front_back(input)
    result = []
    input.lines.each do |line|
      if line =~ / (ssrrr|back separator|back seperator) /i
        transformed = line.sub(/ (ssrrr|back separator|back seperator) /i, ' || ')
        result << make_sr_chunk(transformed)
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
  # 'foo bar make the id.'
  #
  # becomes
  # 'foo bar 2d931510xz'
  def replace_with_uuids(input)
    result = []
    input.lines.each do |line|
      transformed = line.gsub(/make the id\.[ ]*/i, guid() + ": ")
      transformed = transformed.gsub(/mmmiii[ ]*/i, guid() + ": ")
      result << transformed
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

  def guid
    result = []
    10.times do
      result << (('a'..'z').to_a + (0..9).to_a).sample
    end
    result.join
  end

end
