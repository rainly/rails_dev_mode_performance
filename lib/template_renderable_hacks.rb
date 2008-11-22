module ActionView #:nodoc:
  class Template
    
    attr_accessor :last_modified
    
    def source
      @last_modified=File.stat(filename).mtime
      File.read(filename)
    end

    def freeze
      # we don't want to be frozen
      self
    end
    
    def file_changed?
      @last_modified.nil? or File.stat(filename).mtime > @last_modified
    end
    
    def render_template_with_reset(*args)
      if file_changed?
        ["source","compiled_source"].each do |attr|          
          ivar=ActiveSupport::Memoizable::MEMOIZED_IVAR.call(attr)
          instance_variable_get(ivar).clear if instance_variable_defined?(ivar)
        end
      end
      render_template_without_reset(*args)
    end
    
    alias_method_chain :render_template, :reset

  end
end