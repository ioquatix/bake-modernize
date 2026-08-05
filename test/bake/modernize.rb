# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "bake"
require "bake/context"
require "bake/modernize"
require "sus/fixtures/temporary_directory_context"

describe Bake::Modernize do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	it "has a version number" do
		expect(Bake::Modernize::VERSION).to be =~ /^\d+\.\d+\.\d+$/
	end
	
	it "detects stale files when the destination exists" do
		source_path = File.join(root, "source.txt")
		destination_path = File.join(root, "destination.txt")
		
		File.write(source_path, "new")
		File.write(destination_path, "old")
		
		expect(Bake::Modernize.stale?(source_path, destination_path)).to be == true
	end
	
	# let(:context) {Bake::Context.load}
	
	# it "can modernize itself" do
	# 	context.call('modernize')
	# end
end
