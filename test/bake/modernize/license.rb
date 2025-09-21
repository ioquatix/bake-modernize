# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

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

describe Bake::Modernize::License::Contributors do
	let(:mailmap) {Bake::Modernize::License::Mailmap.new}
	let(:contributors) {subject.new(mailmap: mailmap)}
	
	it "can iterate over contributions without mailmap" do
		contributors_without_mailmap = subject.new
		
		contribution = {
			author: {name: "John Doe", email: "john@example.com"},
			time: Time.new(2023, 1, 1),
			path: "test.rb"
		}
		
		contributors_without_mailmap.contributions << contribution
		
		results = []
		contributors_without_mailmap.each do |path, author, time|
			results << {path: path, author: author, time: time}
		end
		
		expect(results.length).to be == 1
		expect(results[0][:path]).to be == "test.rb"
		expect(results[0][:author][:name]).to be == "John Doe"
		expect(results[0][:author][:email]).to be == "john@example.com"
	end
	
	it "applies mailmap transformations when available" do
		mailmap.names["john@old-email.com"] = "John Smith"
		
		contribution = {
			author: {name: "John Doe", email: "john@old-email.com"},
			time: Time.new(2023, 1, 1),
			path: "test.rb"
		}
		
		contributors.contributions << contribution
		
		results = []
		contributors.each do |path, author, time|
			results << {path: path, author: author, time: time}
		end
		
		expect(results.length).to be == 1
		expect(results[0][:author][:name]).to be == "John Smith"
		expect(results[0][:author][:email]).to be == "john@old-email.com"
	end
	
	it "preserves original author data when no mailmap mapping exists" do
		mailmap.names["other@email.com"] = "Other Person"
		
		contribution = {
			author: {name: "John Doe", email: "john@example.com"},
			time: Time.new(2023, 1, 1),
			path: "test.rb"
		}
		
		contributors.contributions << contribution
		
		results = []
		contributors.each do |path, author, time|
			results << {path: path, author: author, time: time}
		end
		
		expect(results.length).to be == 1
		expect(results[0][:author][:name]).to be == "John Doe"
		expect(results[0][:author][:email]).to be == "john@example.com"
	end
	
	it "handles contributions without email address" do
		mailmap.names["john@example.com"] = "John Smith"
		
		contribution = {
			author: {name: "John Doe"},
			time: Time.new(2023, 1, 1),
			path: "test.rb"
		}
		
		contributors.contributions << contribution
		
		results = []
		contributors.each do |path, author, time|
			results << {path: path, author: author, time: time}
		end
		
		expect(results.length).to be == 1
		expect(results[0][:author][:name]).to be == "John Doe"
		expect(results[0][:author][:email]).to be == nil
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
