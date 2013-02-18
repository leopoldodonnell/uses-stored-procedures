$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "uses-stored-procedures/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "uses-store-procedures"
  s.version     = UsesStoreProcedures::VERSION
  s.authors     = ["Leo O'Donnell"]
  s.email       = ["leopold.odonnell@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "Extend ActiveRecord with the ability to use Stored Procedures."
  s.description = "TODO: Description of UsesStoreProcedures."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"

  s.add_development_dependency "sqlite3"
end
