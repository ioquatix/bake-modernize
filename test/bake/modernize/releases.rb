# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/fixtures/async/reactor_context"
require "sus/fixtures/temporary_directory_context"

require_relative "../../../bake/modernize/releases"

describe "modernize:releases" do
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::TemporaryDirectoryContext
	
	let(:bake_path) {File.join(root, "bake.rb")}
	let(:releases_md_path) {File.join(root, "releases.md")}
	
	it "creates releases.md when it does not exist" do
		update_releases_md(releases_md_path)
		
		expect(File.exist?(releases_md_path)).to be_truthy
		expect(File.read(releases_md_path)).to be =~ /Unreleased/
	end
	
	it "does not overwrite a releases.md that already exists" do
		existing_content = "# Releases\n\n## v1.0.0\n\n- Initial release\n"
		File.write(releases_md_path, existing_content)
		
		update_releases_md(releases_md_path)
		
		expect(File.read(releases_md_path)).to be == existing_content
	end
	
	it "creates bake.rb from template when none exists" do
		update_bake(root)
		
		expect(File.exist?(bake_path)).to be_truthy
		expect(File.read(bake_path)).to be =~ /after_gem_release/
	end
	
	it "merges release hooks into an existing bake.rb using AI" do
		existing = <<~RUBY
			# frozen_string_literal: true
			
			def after_gem_release_version_increment(version)
				context["utopia:project:update"].call
			end
		RUBY
		File.write(bake_path, existing)
		
		update_bake(root)
		
		result = File.read(bake_path)
		
		# New release hook added:
		expect(result).to be =~ /def after_gem_release\b/
		# Existing call preserved:
		expect(result).to be =~ /utopia:project:update/
		# Missing call merged in from template:
		expect(result).to be =~ /releases:update/
	end
end
