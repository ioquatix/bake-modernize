# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2023, by Samuel Williams.

require 'bake'
require 'bake/context'
require 'bake/loaders'

describe Bake::Modernize do
	it "has a version number" do
		expect(Bake::Modernize::VERSION).to be =~ /^\d+\.\d+\.\d+$/
	end
	
	# let(:context) {Bake::Context.load}
	
	# it "can modernize itself" do
	# 	context.call('modernize')
	# end
end
