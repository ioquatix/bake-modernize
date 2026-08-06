# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "bake/context"
require "sus/fixtures/temporary_directory_context"

describe "modernize:actions" do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	let(:context) {Bake::Context.load}
	let(:task) {context.lookup("modernize:actions")}
	let(:recipe) {task.instance_variable_get(:@instance)}
	
	it "includes the external test workflow when config/external.yaml exists" do
		FileUtils.mkdir_p(File.join(root, "config"))
		File.write(File.join(root, "config", "external.yaml"), "---\n")
		File.write(File.join(root, "gems.rb"), "source \"https://rubygems.org\"\n")
		
		commands = []
		mock(recipe) do |mock|
			mock.replace(:system) do |*arguments|
				commands << arguments
			end
		end
		
		task.call(root: root)
		
		external_workflow_path = File.join(root, ".github", "workflows", "test-external.yaml")
		expect(File.exist?(external_workflow_path)).to be_truthy
		
		expect(commands).to be(:include?, ["bundle", "add", "bake-test-external", "--group", "test", {chdir: root}])
	end
	
	it "removes the external test workflow when config/external.yaml does not exist" do
		FileUtils.mkdir_p(File.join(root, ".github", "workflows"))
		File.write(File.join(root, ".github", "workflows", "test-external.yaml"), "name: Test External\n")
		File.write(File.join(root, "gems.rb"), %(source "https://rubygems.org"\ngem "bake-test-external"\n))
		
		commands = []
		mock(recipe) do |mock|
			mock.replace(:system) do |*arguments|
				commands << arguments
			end
		end
		
		task.call(root: root)
		
		external_workflow_path = File.join(root, ".github", "workflows", "test-external.yaml")
		expect(File.exist?(external_workflow_path)).to be_falsey
		
		expect(commands).to be(:include?, ["bundle", "remove", "bake-test-external", {chdir: root}])
	end
end
