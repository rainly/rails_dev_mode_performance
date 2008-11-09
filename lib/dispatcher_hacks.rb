ActionController::Dispatcher.class_eval do

  # Cleanup the application by clearing out loaded classes so they can
  # be reloaded on the next request without restarting the server.
  def cleanup_application
    # ActiveRecord::Base.reset_subclasses if defined?(ActiveRecord)
    # ActiveSupport::Dependencies.clear
    # ActiveRecord::Base.clear_reloadable_connections! if defined?(ActiveRecord)
  end
  
  def reload_application
   ActiveSupport::Dependencies.clear

    # Run prepare callbacks before every request in development mode
    run_callbacks :prepare_dispatch

    ActionController::Routing::Routes.reload
    # we'll be pathing template finder to only do a reload in the case
    # of a problem (missing template, error loading cached template)
#    ActionView::TemplateFinder.reload! unless ActionView::Base.cache_template_loading
  end
  

end

