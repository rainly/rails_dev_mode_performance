# these hacks are only for faster development
if RAILS_ENV=="development"
  # we need to load the rails dispatcher because normally it's not loaded so early
  require 'dispatcher'
  
  # these hacks kind of change everything around
  require 'dispatcher_hacks'
  require 'dep_hacks'
  # should be 100% safe hacks
  require 'template_finder_hacks'
end

