# frozen_string_literal: true

def frozen_string_literal
	update(root: Dir.pwd)
end

def update(root:)
	Dir.glob("**/*.rb", base: root).each do |path|
		case path
		when /\.rb$/
			update_source_file(path)
		end
	end
end

private

def update_source_file(path)
	input = File.readlines(path)
	output = []
	
	# Skip the hash-bang line:
	if input.first =~ /^\#!/
		output.push input.shift
	end
	
	options = {}
	
	while input.first =~ /^\#\s*(.*?):(.*)$/
		options[$1.strip] = $2.strip
		input.shift
	end
	
	options['frozen_string_literal'] ||= 'true'
	
	options.each do |key, value|
		output.push "# #{key}: #{value}"
	end
	
	unless input.first&.chomp&.empty?
		output.push "\n"
	end
	
	# Add the rest of the file:
	output.push(*input)
	
	File.open(path, "w") do |file|
		file.puts(output)
	end
end
