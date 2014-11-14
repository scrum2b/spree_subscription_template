Spree::Taxonomy.class_eval do

  FACTORS = {
    :relationship => ["spouse", "parent", "child", "sibling", "cousin", "significant other", "friend", "romantic interest", "colleague", "business associate"],
    :pronoun => ['his', 'her', 'our'],
    :occasion => ["birthday", "anniversary", "wedding", "baby event", "graduation", "promotion", "retirement", "housewarming", "thank you", "upcoming holidays"],
    :event_occasion => ["Wedding", "Baby Event", "Bar/Bat Mitzvah", "Other"],
    :profession => ["employed professional", "artist", "student", "retiree", "homemaker", "entrepreneur", "unemployed"],
    :living_arrangement => ['alone', 'with me', 'with family', 'with roommates'],
    :location => ["New York City Tristate", "San Francisco Bay Area", "Los Angeles and surrounding", "Greater Chicago Area", "Boston / Cambridge", "Greater Houston Area", "Input other US location"],
    :dresscode => ["Business-like", "Style conscious", "Utilitarian", "Super casual"],
    :beverage =>["Coffee", "Tea", "Water", "Juice", "Soda", "Alcohol"],
    :leisure_activity => ["Quiet relaxation", "Upbeat parties", "Time with family", "Socializing with friends", "Outdoors", "Sporting events", "Movies", "Museums and performing arts"],
    :habitat => ["City loft", "Suburban home", "Seaside bungalow", "Stately mansion", "Mountain chalet", "Lakeside cottage"],
    :home_decor => ["Photos of people", "Colorful artwork", "Books", "Minimalist Design", "A little bit of everything", "I don't know"],
    :orderliness => ["Totally messy", "Very organized", "Cluttered", "I don't know"],
    :vacation_preference => ["Beach holiday", "City sightseeing", "Foreign destination", "Exotic locale", "Shopping", "Staycation"],
    :other => ["Newborn", "Toddler", "Teenager", "Dog", "Cat", "Relocation", "New job", "Promotion", "Marriage"],
    :product => {
                 :type => ["Personal", "Romantic", "Platonic", "Family", "Home", "Business", "Travel", "Major Milestone", "Ethnic", "Innovative"],
                 :utility => ["Functional", "Value", "Aesthetic", "Vanity", "Fantasy", "Serious", "Humorous", "Innovative", "Trendy", "Good Cause"]
                },
    :category => {
                  :experiental => ["Outdoors", "Adventure", "Arts/Culture", "Learning", "Social", "Dinning", "Theatre", "Sport Events"],
                  :physical_products => ["Accessories", "Artistic/Design", "Gadgets/Games", "Interior Dcor/HH", "New/Innovative", "Babies/Children", "Pets", "Gourmet Foods", "Jewelry", "Eco/Sustble/Grn/FT"]
                },
    :gender => ["Male", "Female", "Unisex"],
    :age_range => ["0-17", "18-21", "21-26", "26-31", "32-39", "40-49", "50-59", "60-65", "66-75", "75-199"],
    :price_range => ["$25-50", "$50-100", "$75-125", "$100-200", "$150-300"],
    :socio_econ => [ "0", "1", "2", "3", "4"],
  }
  BANK_NAME = ["a", "b", "c", "d"," e", "f"]

  # Populate Spree Taxonomy with the FACTORS structure
  #   can be re-run if the string for a given index is changed, or if additional indexes or keys are added,
  #   but cannot detect when key names (or sub-names) are changed, or when values are reordered or removed
  def self.generate_default_taxons
    FACTORS.keys.each do |key|
      taxonomy_name = key.to_s.humanize
      if FACTORS[key].class == Array
        taxonomy = Spree::Taxonomy.find_or_create_by_name(taxonomy_name)
        FACTORS[key].each_with_index do |key2, index|
          taxon = taxonomy.taxons.find_or_initialize_by_taxonomy_id_and_parent_id_and_position(taxonomy.id, taxonomy.root.id, (index + 1))
          taxon.name = key2
          taxon.save!
        end
      else
        FACTORS[key].keys.each do |key2|
          sub_name = key2.to_s.split('_').first
          taxonomy = Spree::Taxonomy.find_or_create_by_name("#{taxonomy_name} #{sub_name}")
          FACTORS[key][key2].each_with_index do |key3, index|
            taxon = taxonomy.taxons.find_or_initialize_by_taxonomy_id_and_parent_id_and_position(taxonomy.id, taxonomy.root.id, (index + 1))
            taxon.name = key3
            taxon.save!
          end
        end
      end
    end
  end
end