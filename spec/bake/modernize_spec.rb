# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require 'bake'
require 'bake/context'
require 'bake/loaders'

RSpec.describe Bake::Modernize do
	it "has a version number" do
		expect(Bake::Modernize::VERSION).not_to be nil
	end
	
	subject {Bake::Context.load}
	
	it "can modernize itself" do
		subject.call('modernize')
	end
end
