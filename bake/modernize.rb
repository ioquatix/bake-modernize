
def modernize
	call('modernize:git', 'modernize:actions', 'modernize:editorconfig', 'modernize:gemfile', 'modernize:signing', 'modernize:gemspec')
end
