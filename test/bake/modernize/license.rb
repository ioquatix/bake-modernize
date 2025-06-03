# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require "bake/modernize/license"

describe Bake::Modernize::License::Mailmap do
	let(:mailmap) {subject.new}
	
	it "can parse a proper name and commit email" do
		user = mailmap.extract_from_line("Samuel Williams <samuel@example.org>")
		
		expect(user[:proper_name]).to be == "Samuel Williams"
		expect(user[:commit_email]).to be == "samuel@example.org"
	end
	
	it "can parse a proper name, commit name and commit email" do
		user = mailmap.extract_from_line("Samuel Williams <samuel@example.org> <ioquatix@example.org>")
		
		expect(user[:proper_name]).to be == "Samuel Williams"
		expect(user[:proper_email]).to be == "samuel@example.org"
		expect(user[:commit_email]).to be == "ioquatix@example.org"
	end
	
	it "can parse a proper name, proper email, commit name and commit email" do
		user = mailmap.extract_from_line("Samuel Williams <samuel@example.org> ioquatix <ioquatix@example.org>")
		
		expect(user[:proper_name]).to be == "Samuel Williams"
		expect(user[:proper_email]).to be == "samuel@example.org"
		expect(user[:commit_name]).to be == "ioquatix"
		expect(user[:commit_email]).to be == "ioquatix@example.org"
	end
end

describe Bake::Modernize::License::Authorship::Copyright do
	it "adds period when author doesn't end with one" do
		copyright = subject.new([Time.new(2023), Time.new(2024)], "Samuel Williams")
		
		expect(copyright.statement).to be == "Copyright, 2023-2024, by Samuel Williams."
	end
	
	it "doesn't add extra period when author already ends with one" do
		copyright = subject.new([Time.new(2023), Time.new(2024)], "Widgets Inc.")
		
		expect(copyright.statement).to be == "Copyright, 2023-2024, by Widgets Inc."
	end
end
