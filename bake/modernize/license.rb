
require 'console'

LICENSE = <<~LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE

# @parameter root [String] The root directory to scan for changes.
def license
	update(root: Dir.pwd)
end

def update(root:)
	authors = self.authors(root)
	
	buffer = StringIO.new
	buffer.puts "# MIT License"
	buffer.puts
	
	authors.map do |author, dates|
		years = dates.map(&:year).uniq
		
		buffer.puts "Copyright, #{years.join('-')}, by #{author}."
	end
	
	buffer.puts
	buffer.puts LICENSE
	
	File.open("license.md", "w") do |file|
		file.write(buffer.string)
	end
end

private

def authors(root)
	paths = {}
	authors = {}

	total = `git rev-list --count HEAD`.to_i

	input, output = IO.pipe
	pid = Process.spawn("git", "log", "--name-only", "--pretty=format:%ad\t%an", out: output, chdir: root)

	output.close

	progress = Console.logger.progress(self, total)

	while header = (input.readline.chomp rescue nil)
		break if header.empty?
		progress.increment

		date, author = header.split("\t", 2)
		date = Date.parse(date)

		while path = (input.readline.chomp rescue nil)
			break if path.empty?

			paths[path] ||= {}
			paths[path][author] ||= []
			paths[path][author] << date

			authors[author] ||= []
			authors[author] << date
		end
	end

	input.close
	Process.wait2(pid)

	paths.each do |path, authors|
		authors.transform_values! do |dates|
			dates.minmax
		end
	end

	authors.transform_values! do |dates|
		dates.minmax
	end.to_a.sort_by! do |author, dates|
		dates
	end

	return authors
end
