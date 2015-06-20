class RandStringGenerator

  def self.rand_string_of_length(length)
    (0...length).map { (65 + rand(26)).chr }.join.downcase
  end

end
