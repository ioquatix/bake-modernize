source "https://rubygems.org"

# Specify your gem's dependencies in bake-modernize.gemspec
gemspec

# gem "build-files", path: "../build-files"

group :test do
	gem "rspec", "~> 3.9"
end
