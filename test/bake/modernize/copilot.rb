# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Copilot.
# Copyright, 2025-2026, by Samuel Williams.

require "sus/fixtures/temporary_directory_context"
require "bake/context"

describe "modernize:copilot" do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	let(:context) {Bake::Context.load}
	
	it "can be invoked with a root path" do
		context.lookup("modernize:copilot").call(root: root)
		
		copilot_file = File.join(root, ".github", "copilot-instructions.md")
		expect(File.exist?(copilot_file)).to be_truthy
		
		content = File.read(copilot_file)
		expect(content).to be =~ /bundle exec bake agent:context:install/
		expect(content).to be =~ /agents\.md/
	end
end
