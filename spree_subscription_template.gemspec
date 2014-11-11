$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spree_subscription_template/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "Spree Storefront for Subscription Template"
  s.version     = SpreeSubscriptionTemplate::VERSION
  s.authors     = ["ScrumTobe Software"]
  s.email       = ["scrum2b@ithanoi.com"]
  s.homepage    = "www.scrumtobe.com"
  s.summary     = "Spree Storefront for Subscription Template."
  s.description = "Spree Storefront for Subscription Template."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.4"

  s.add_development_dependency "sqlite3"
end
