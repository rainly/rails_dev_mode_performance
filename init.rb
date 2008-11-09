# these hacks are only for faster development
if RAILS_ENV=="development"
# we need to load the rails dispatcher because normally it's not loaded so early
  require 'dispatcher'
  require 'dispatcher_hacks'
  # ActiveSupport::Dependencies
  # ActionView::TemplateFinder
  require 'dep_hacks'
  require 'template_finder_hacks'
end

