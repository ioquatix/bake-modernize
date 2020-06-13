
require 'bake/modernize'
require 'rugged'
require 'markly'

def actions
	update(root: Dir.pwd)
end

def update(root:)
	travis_path = File.expand_path(".travis.yml", root)
	
	if File.exist?(travis_path)
		FileUtils.rm_rf(travis_path)
	end
	
	template_root = Bake::Modernize.template_path_for('actions')
	Bake::Modernize.copy_template(template_root, root)
	
	readme_path = File.expand_path("README.md", root)
	repository_url = self.repository_url(root)
	self.update_badges(readme_path, repository_url)
end

private

def repository_url(root)
	repository = Rugged::Repository.discover(root)
	git_url = repository.remotes['origin'].url
	
	if match = git_url.match(/@(?<url>.*?):(?<path>.*?)(\.git)?\z/)
		return "https://#{match[:url]}/#{match[:path]}"
	end
end

def badge_for(repository_url = self.repository_url)
	"[![Development Status](#{repository_url}/workflows/Development/badge.svg)](#{repository_url}/actions?workflow=Development)"
end

def badge?(node)
	return false unless node.type == :link
	return node.all?{|child| child.type == :image}
end

def badges?(node)
	node.any?{|child| badge?(child)}
end

def update_badges(readme_path, repository_url)
	root = Markly.parse(File.read(readme_path))
	
	node = root.first_child
	
	# Skip heading:
	node = node.next if node.type == :header
	
	replacement = Markly.parse(badge_for(repository_url))
	
	# We are looking for the first paragraph which contains only links, which contain one image.
	while node
		if badges?(node)
			node = node.replace(replacement.first_child)
			break
		elsif node.type == :header
			node.insert_before(replacement.first_child)
			break
		end
		
		node = node.next
	end
	
	File.write(readme_path, root.to_markdown(width: 0))
end
