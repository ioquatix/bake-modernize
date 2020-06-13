
require_relative "lib/bake/modernize/version"

Gem::Specification.new do |spec|
	spec.name = "bake-modernize"
	spec.version = Bake::Modernize::VERSION
	
	spec.summary = "Automatically modernize parts of your project/gem."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/ioquatix/bake-modernize"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{bake,lib,template}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = "~> 2.5"
	
	spec.add_dependency "async-http"
	spec.add_dependency "bake"
	spec.add_dependency "build-files", "~> 1.6"
	spec.add_dependency "markly"
	spec.add_dependency "rugged"
	
	spec.add_development_dependency "bake-bundler"
end
