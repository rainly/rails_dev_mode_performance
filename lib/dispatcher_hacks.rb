ActionController::Dispatcher.class_eval do

  # Cleanup the application by clearing out loaded classes so they can
  # be reloaded on the next request without restarting the server.
  def cleanup_application
#   ActiveRecord::Base.reset_subclasses if defined?(ActiveRecord)
#    ActiveSupport::Dependencies.clear
    # uncomment this if your using sqlite3 in development
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

module ActionView
  class TemplateFinder
   
    class << self #:nodoc:

      # This method is not thread safe. Mutex should be used whenever this is accessed from an instance method
      def process_view_paths(*view_paths)
        view_paths.flatten.compact.each do |dir|
          next if @@processed_view_paths.has_key?(dir) and not @@force_reload
          @@processed_view_paths[dir] = []

          # 
          # Dir.glob("#{dir}/**/*/**") reads all the directories in view path and templates inside those directories
          # Dir.glob("#{dir}/**") reads templates residing at top level of view path
          # 
          (Dir.glob("#{dir}/**/*/**") | Dir.glob("#{dir}/**")).each do |file|
            unless File.directory?(file)
              @@processed_view_paths[dir] << file.split(dir).last.sub(/^\//, '')

              # Build extension cache
              extension = file.split(".").last
              if template_handler_extensions.include?(extension)
                key = file.split(dir).last.sub(/^\//, '').sub(/\.(\w+)$/, '')
                @@file_extension_cache[dir][key] << extension
              end
            end
          end
        end
      end
    end
   
    
  end
end

ActionView::TemplateFinder.class_eval do
  
  def file_exists_with_auto_reload?(path)
    result=file_exists_without_auto_reload?(path)
    unless result
      @@force_reload=true
      self.view_paths=view_paths
      result=file_exists_without_auto_reload?(path)
    end
    result
  end
  
  alias_method_chain :file_exists?, :auto_reload  
  
end