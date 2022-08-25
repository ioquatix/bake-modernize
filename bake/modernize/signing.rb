# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require 'bake/modernize'

def signing
	update(root: Dir.pwd)
end

def update(root:)
	release_certificate_path = File.expand_path("~/.gem/release.cert")
	certificate_path = File.expand_path("release.cert", root)
	
	if File.exist?(release_certificate_path)
		FileUtils.cp(release_certificate_path, certificate_path)
	end
end
