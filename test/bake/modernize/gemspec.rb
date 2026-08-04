# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "bake/context"
require "bake/modernize"
require "sus/fixtures/temporary_directory_context"

describe "modernize:gemspec" do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	let(:context) {Bake::Context.load(Dir.pwd)}
	let(:gemspec_path) {File.join(root, "example.gemspec")}
	let(:output) {StringIO.new}
	
	def write_project(metadata = {})
		version_path = File.join(root, "lib", "example", "version.rb")
		FileUtils.mkdir_p(File.dirname(version_path))
		File.write(version_path, <<~RUBY)
			module Example
				VERSION = "1.0.0"
			end
		RUBY
		
		metadata = {
			"documentation_uri" => "https://socketry.github.io/example/",
			"funding_uri" => "https://github.com/sponsors/socketry/",
			"source_code_uri" => "https://github.com/socketry/example.git",
		}.merge(metadata)
		
		File.write(gemspec_path, <<~RUBY)
			# frozen_string_literal: true
			
			Gem::Specification.new do |spec|
				spec.name = "example"
				spec.version = "1.0.0"
				
				spec.summary = "An example gem."
				spec.authors = ["Samuel Williams"]
				spec.license = "MIT"
				
				spec.homepage = "https://github.com/socketry/example"
				
				spec.metadata = #{metadata.inspect}
				
				spec.files = Dir["lib/**/*.rb", base: __dir__]
			end
		RUBY
		
		repository = Rugged::Repository.init_at(root)
		repository.index.add_all
		repository.index.write
		
		signature = {name: "Samuel Williams", email: "samuel@example.com", time: Time.now}
		tree = repository.index.write_tree(repository)
		
		Rugged::Commit.create(
			repository,
			message: "Initial commit",
			author: signature,
			committer: signature,
			parents: [],
			tree: tree,
			update_ref: "HEAD",
		)
	end
	
	def update_gemspec
		recipe = context.lookup("modernize:gemspec:update")
		
		Dir.chdir(root) do
			recipe.call(path: gemspec_path, output: output)
		end
		
		return output.string
	end
	
	it "adds GitHub bug tracker metadata" do
		write_project
		
		result = update_gemspec
		
		expect(result).to be(:include?, %("bug_tracker_uri" => "https://github.com/socketry/example/issues"))
	end
	
	it "adds changelog metadata when releases.md exists" do
		write_project
		File.write(File.join(root, "releases.md"), "# Releases\n")
		
		result = update_gemspec
		
		expect(result).to be(:include?, %("changelog_uri" => "https://github.com/socketry/example/blob/main/releases.md"))
	end
	
	it "does not add changelog metadata without releases.md" do
		write_project
		
		result = update_gemspec
		
		expect(result).not.to be(:include?, "changelog_uri")
	end
	
	it "preserves existing metadata" do
		write_project(
			"bug_tracker_uri" => "https://example.com/issues",
			"changelog_uri" => "https://example.com/changelog",
		)
		
		result = update_gemspec
		
		expect(result).to be(:include?, %("bug_tracker_uri" => "https://example.com/issues"))
		expect(result).to be(:include?, %("changelog_uri" => "https://example.com/changelog"))
	end
end
