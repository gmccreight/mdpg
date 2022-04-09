# frozen_string_literal: true

# To be able to export to obsidian we need to make changes to the text.
# This is highly specialized

class AdapterObsidianExporter
  def transform(input)
    result = input
    result = transform_transclusion_links(result)
    result = transform_named_block(result)
    result
  end

  # [[video-bullet-proof-nest-egg#breakdown-of-allocations-by-ray-dalio:short]]
  # becomes
  # ![[video-bullet-proof-nest-egg#^breakdown-of-allocations-by-ray-dalio]]
  def transform_transclusion_links(input)
    result = []
    min = Token::TOKEN_MIN_LENGTH
    max = Token::TOKEN_MAX_LENGTH
    input.lines.each do |line|
      transformed = line.gsub(/\[\[([a-z0-9-]{#{min},#{max}})#([a-z0-9-]{#{min},#{max}}):short\]\]/) do
        page_name = Regexp.last_match(1)
        section = Regexp.last_match(2)
        "![[#{page_name}#^#{section}]]"
      end
      result << transformed
    end
    result = result.join
  end

  # [[#foo-bar:dudcwcrnzgodqmaupfzgbzmyzuqkvndg]]the deal[[#foo-bar:dudcwcrnzgodqmaupfzgbzmyzuqkvndg]]
  # becomes
  # the deal ^foo-bar

  def transform_named_block(input)
    already_processed = {}
    result = input.gsub(section_regex(remove_space: false)) do
      name = Regexp.last_match(1)
      if ! already_processed.key?(name)
        already_processed[name] = true
        ""
      else
        # Only keep the second one (at the end)
        " ^#{name}"
      end
    end
    result
  end

  private def section_regex(remove_space:)
    internal = "
      \\[\\[
      [#](#{Token::TOKEN_REGEX_STR})
      (:#{Token::TOKEN_REGEX_STR})?
      ((?::|::)#{LabeledSectionTranscluder::OPTS_REGEX_STR})?
      \\]\\]
    "
    if remove_space
      /\s?#{internal}\s?/x
    else
      /#{internal}/x
    end
  end

end
