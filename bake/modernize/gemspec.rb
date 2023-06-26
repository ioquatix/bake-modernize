# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

# Rewrite the current gemspec.
def gemspec
	path = default_gemspec_path
	buffer = StringIO.new
	
	update(path: path, output: buffer)
	
	File.write(path, buffer.string)
end

# The latest end-of-life Ruby version.
LATEST_END_OF_LIFE_RUBY = ::Gem::Version.new("2.7")
MINIMUM_RUBY_VERSION = ::Gem::Requirement.new(">= 3.0")

# Rewrite the specified gemspec.
# @param
def update(path: default_gemspec_path, output: $stdout)
	spec = ::Gem::Specification.load(path)
	
	root = File.dirname(path)
	version_path = version_path(root)
	
	constant = File.read(version_path)
		.scan(/module\s+(.*?)$/)
		.flatten
		.join("::")
	
	spec.metadata["funding_uri"] ||= detect_funding_uri(spec)
	spec.metadata["documentation_uri"] ||= detect_documentation_uri(spec)
	
	spec.authors = sorted_authors(spec)
	
	spec.metadata.delete_if{|_, value| value.nil?}
	
	output.puts "# frozen_string_literal: true"
	output.puts
	output.puts "require_relative #{version_path.sub(/\.rb$/, '').inspect}"
	output.puts
	output.puts "Gem::Specification.new do |spec|"
	output.puts "\tspec.name = #{spec.name.dump}"
	output.puts "\tspec.version = #{constant}::VERSION"
	output.puts "\t"
	output.puts "\tspec.summary = #{spec.summary.inspect}"
	output.puts "\tspec.authors = #{spec.authors.inspect}"
	output.puts "\tspec.license = #{spec.license.inspect}"
	
	certificate_path = File.expand_path('release.cert', root)
	
	if File.exist?(certificate_path)
		output.puts "\t"
		output.puts "\tspec.cert_chain  = ['release.cert']"
		output.puts "\tspec.signing_key = File.expand_path('~/.gem/release.pem')"
	end
	
	if spec.homepage and !spec.homepage.empty?
		output.puts "\t"
		output.puts "\tspec.homepage = #{spec.homepage.inspect}"
	end
	
	if spec.metadata.any?
		output.puts "\t"
		output.puts "\tspec.metadata = {"
		spec.metadata.sort.each do |key, value|
			output.puts "\t\t#{key.inspect} => #{value.inspect},"
		end
		output.puts "\t}"
	end
	
	output.puts "\t"
	output.puts "\tspec.files = #{directory_glob_for(spec)}"
	
	if spec.require_paths != ['lib']
		output.puts "\tspec.require_paths = ['lib']"
	end
	
	if executables = spec.executables and executables.any?
		output.puts "\t"
		output.puts "\tspec.executables = #{executables.inspect}"
	end
	
	if extensions = spec.extensions and extensions.any?
		output.puts "\t"
		output.puts "\tspec.extensions = #{extensions.inspect}"
	end
	
	if required_ruby_version = spec.required_ruby_version
		unless required_ruby_version.none?
			if required_ruby_version.satisfied_by?(LATEST_END_OF_LIFE_RUBY)
				Console.logger.warn(self, "Required Ruby version #{required_ruby_version} is end-of-life!")
			end
			
			output.puts "\t"
			output.puts "\tspec.required_ruby_version = #{required_ruby_version.to_s.inspect}"
		end
	else
		output.puts "\t"
		output.puts "\tspec.required_ruby_version = #{MINIMUM_RUBY_VERSION.to_s.dump}"
	end
	
	if spec.runtime_dependencies.any?
		output.puts "\t"
		spec.runtime_dependencies.sort.each do |dependency|
			output.puts "\tspec.add_dependency #{format_dependency(dependency)}"
		end
	end
	
	if spec.development_dependencies.any?
		output.puts "\t"
		spec.development_dependencies.sort.each do |dependency|
			output.puts "\tspec.add_development_dependency #{format_dependency(dependency)}"
		end
	end
	
	output.puts "end"
end

private

def directory_glob_for(spec, paths = spec.files)
	directories = {}
	root = File.dirname(spec.loaded_from)
	dotfiles = false
	
	paths.each do |path|
		directory, _ = path.split(File::SEPARATOR, 2)
		basename = File.basename(path)
		
		full_path = File.expand_path(directory, root)
		
		if File.directory?(full_path)
			directories[directory] = true
		end
		
		if basename.start_with?('.')
			dotfiles = true
		end
	end
	
	if dotfiles
		return "Dir.glob(['{#{directories.keys.join(',')}}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)"
	else
		return "Dir['{#{directories.keys.join(',')}}/**/*', '*.md', base: __dir__]"
	end
end

def format_dependency(dependency)
	requirements = dependency.requirements_list
	
	if requirements.size == 1
		requirements = requirements.first
	end
	
	if requirements == ">= 0"
		requirements = nil
	end
	
	if dependency.name == "bundler"
		requirements = nil
	end
	
	if requirements
		"#{dependency.name.inspect}, #{requirements.inspect}"
	else
		"#{dependency.name.inspect}"
	end
end

def default_gemspec_path
	Dir["*.gemspec"].first
end

def version_path(root)
	Dir["lib/**/version.rb", base: root].first
end

require 'async'
require 'async/http/internet'

def valid_uri?(uri)
	Sync do
		internet = Async::HTTP::Internet.new
		response = internet.head(uri)
		
		next response.success?
	end
end

GITHUB_PROJECT = /github.com\/(?<account>.*?)\/(?<project>.*?)\/?/

def detect_funding_uri(spec)
	if match = spec.homepage&.match(GITHUB_PROJECT)
		account = match[:account]
		
		funding_uri = "https://github.com/sponsors/#{account}/"
		
		if valid_uri?(funding_uri)
			return funding_uri
		end
	end
end

def detect_documentation_uri(spec)
	if match = spec.homepage.match(GITHUB_PROJECT)
		account = match[:account]
		project = match[:project]
		
		documentation_uri = "https://#{account}.github.io/#{project}/"
		
		if valid_uri?(documentation_uri)
			return documentation_uri
		end
	end
end

def sorted_authors(spec)
	input, output = IO.pipe
	
	pid = Process.spawn("git", "log", "--format=%aN", out: output)
	output.close
	
	authors = Hash.new{|h,k| h[k] = 0}
	
	input.each_line do |author|
		author = author.chomp!
		authors[author] += 1
	end
	
	Process.wait(pid)
	input.close
	
	return authors.sort_by{|k,v| [-v, k]}.map(&:first)
end
