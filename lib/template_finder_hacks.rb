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

  # if the template doesn't exist the first time we need to reload 
  # the view path cache and try again incase it's changed
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
  
  # if a file that used to be in place can no longer be found
  # then we need to return false, which will coincidentally
  # force an auto-reload which will remove this bad data so
  # it won't befound next request cycle
  def find_base_path_for(template_file_name)
    p=@view_paths.find { |path| self.class.processed_view_paths[path].include?(template_file_name) }
    return p if p and File.exists?(File.join(p, template_file_name))
  end  
  
end