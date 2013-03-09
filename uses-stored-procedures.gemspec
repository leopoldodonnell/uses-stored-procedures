$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "uses_stored_procedures/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "uses-stored-procedures"
  s.version     = UsesStoreProcedures::VERSION
  s.authors     = ["Leo O'Donnell"]
  s.email       = ["leopold.odonnell@gmail.com"]
  s.homepage    = "https://github.com/leopoldodonnell/uses-stored-procedures"
  s.summary     = "Extend ActiveRecord with the ability to use Stored Procedures."
  s.description =<<-EOF.gsub(/ {4}/, '')
    So, you really need to use stored procedures in your Rails application. This gem extends
    ActiveRecord with a class method to add to your models or services.
  EOF
  s.has_rdoc    = 'yard'
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
end
