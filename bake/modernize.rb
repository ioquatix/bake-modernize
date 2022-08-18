
def modernize
	call('modernize:git', 'modernize:readme', 'modernize:actions', 'modernize:editorconfig', 'modernize:gemfile', 'modernize:signing', 'modernize:gemspec', 'modernize:license')
end
