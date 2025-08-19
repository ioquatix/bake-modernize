# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "fileutils"

describe "modernize:copilot" do
	let(:test_root) { File.join(__dir__, "../..", "..", "tmp", "copilot_test") }
	
	before do
		FileUtils.mkdir_p(test_root)
		FileUtils.mkdir_p(File.join(test_root, ".github"))
	end
	
	after do
		FileUtils.rm_rf(test_root) if File.exist?(test_root)
	end
	
	it "creates copilot-instructions.md file" do
		# Load the copilot task
		require_relative "../../../bake/modernize/copilot"
		
		# Execute the update function
		update(root: test_root)
		
		# Verify the file was created
		copilot_file = File.join(test_root, ".github", "copilot-instructions.md")
		expect(File.exist?(copilot_file)).to be_truthy
		
		# Verify content includes required information
		content = File.read(copilot_file)
		expect(content =~ /bake agent:context:install/).to be_truthy
		expect(content =~ /agent\.md/).to be_truthy
	end
end