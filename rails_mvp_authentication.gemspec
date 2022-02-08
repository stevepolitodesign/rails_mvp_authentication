require_relative "lib/rails_mvp_authentication/version"

Gem::Specification.new do |spec|
  spec.name = "rails_mvp_authentication"
  spec.version = RailsMvpAuthentication::VERSION
  spec.authors = ["Steve Polito"]
  spec.email = ["stevepolito@hey.com"]
  spec.homepage = "https://github.com/stevepolitodesign/rails_mvp_authentication"
  spec.summary = "Rails authentication via a generator."
  spec.description = "Rails authentication via a generator."
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/stevepolitodesign/rails_mvp_authentication"
  spec.metadata["changelog_uri"] = "https://github.com/stevepolitodesign/rails_mvp_authentication/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "sprockets-rails", "~> 3.4", ">= 3.4.2"
end
