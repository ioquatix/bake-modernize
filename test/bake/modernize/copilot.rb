# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Copilot.
# Copyright, 2025, by Samuel Williams.

require "sus/fixtures/temporary_directory_context"
require_relative "../../../bake/modernize/copilot"

describe "modernize:copilot" do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	it "creates copilot-instructions.md file" do
		update(root: root)
		
		copilot_file = File.join(root, ".github", "copilot-instructions.md")
		expect(File.exist?(copilot_file)).to be_truthy
		
		content = File.read(copilot_file)
		expect(content).to be =~ /bundle exec bake agent:context:install/
		expect(content).to be =~ /agents\.md/
	end
end
