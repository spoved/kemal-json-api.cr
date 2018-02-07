class String
  # Will retuen a pluralized string of self
  # ```
  # "wolf".pluralize => "wolves"
  # ```
  def pluralize : String
    exemptions = {
      "fez":    "fezzes",
      "gas":    "gasses",
      "photo":  "photos",
      "piano":  "pianos",
      "halo":   "halos",
      "puppy":  "puppies",
      "roof":   "roofs",
      "belief": "beliefs",
      "chef":   "chefs",
      "chief":  "chiefs",
    }
    return exemptions[self] if exemptions.has_key?(self)

    case self
    when /^metadum$/
      "#{self[0..-3]}ata"
    when /\w{2}+us$/
      "#{self[0..-3]}i"
    when /is$/
      "#{self[0..-3]}es"
    when /(s|ss|sh|x|z|ch)$/
      "#{self}es"
    when /(a|e|i|o|u)y$/
      "#{self}s"
    when /o$/
      "#{self}es"
    when /y$/
      "#{self[0..-2]}ies"
    when /f$/
      "#{self[0..-2]}ves"
    when /fe$/
      "#{self[0..-3]}ves"
    when /on$/
      "#{self[0..-3]}a"
    else
      "#{self}s"
    end
  end
end
