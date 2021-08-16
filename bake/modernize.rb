
def modernize
	call('modernize:actions', 'modernize:editorconfig', 'modernize:gemfile', 'modernize:signing', 'modernize:gemspec')
end
