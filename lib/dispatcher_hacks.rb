ActionController::Dispatcher.class_eval do

  # Cleanup the application by clearing out loaded classes so they can
  # be reloaded on the next request without restarting the server.
  def cleanup_application
    puts "CLEAN UP"
#   ActiveRecord::Base.reset_subclasses if defined?(ActiveRecord)
#    ActiveSupport::Dependencies.clear
    # uncomment this if your using sqlite3 in development
    # ActiveRecord::Base.clear_reloadable_connections! if defined?(ActiveRecord)
  end
  
  def reload_application
    puts "RELOAD APP"
    ActiveSupport::Dependencies.clear

    # Run prepare callbacks before every request in development mode
    run_callbacks :prepare_dispatch

    ActionController::Routing::Routes.reload
   ActionView::TemplateFinder.reload! unless ActionView::Base.cache_template_loading
  end
  

end
