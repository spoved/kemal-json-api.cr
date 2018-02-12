require "../spec_helper"

describe String do
  describe "#pluralize" do
    words = {
      "cat":        "cats",
      "house":      "houses",
      "truss":      "trusses",
      "bus":        "buses",
      "marsh":      "marshes",
      "lunch":      "lunches",
      "tax":        "taxes",
      "blitz":      "blitzes",
      "wife":       "wives",
      "wolf":       "wolves",
      "city":       "cities",
      "ray":        "rays",
      "boy":        "boys",
      "potato":     "potatoes",
      "tomato":     "tomatoes",
      "cactus":     "cacti",
      "focus":      "foci",
      "analysis":   "analyses",
      "ellipsis":   "ellipses",
      "phenomenon": "phenomena",
      "criterion":  "criteria",
      "metadum":    "metadata",

      # Exemptions
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

    words.each do |singular, plural|
      it "correctly pluralizes the String #{singular}" do
        singular.to_s.pluralize.should eq plural
      end
    end
  end
end
