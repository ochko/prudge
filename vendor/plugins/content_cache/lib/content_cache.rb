# Content caching is a different level of granularity for Rails. Like action
# caching, requests are routed through the ActionController framework. Unlike
# action caching, none of the layout is cached, allowing you to provide some
# dynamic, user-specific content while reducing DB loads and rendering times.
# It's a bit like fragement caching, but if a copy exists in the cache, the
# controller action isn't called.
#
# For example:
#
#   class NotesController < ActionController::Base
#     caches_action_content :index
#     
#     def index
#       @notes = Note.find(:all, :include => [:monkeys, dirigibles, robots])
#     end
#   end
#
# The first time /notes/index is requested, #index is executed and whatever it
# renders is stored wherever you have the cache store configured. None of the
# layout is stored, just the rendered view. The next time /notes/index is
# requested, the cached action content is read from the cache, placed within the
# layout, and sent to the client.
#
# Sometimes an action's instance variables are used in the layout itself--to set
# the title, for example. Instance variables your layout depends on can be
# specified as such:
#
#   ActionContentFilter.preserved_instance_variables += ['@title', '@content_type']
#
# The content of these instance variables are cached alongside the action's
# content, and sent to the layout during a request. (These types are marshalled,
# which means that simple data types are preferred, and anything which refers to
# records in a database will likely break after a certain period of time. Best
# to limit this to strings, integers, arrays, and other simple types which play
# well with marshalling.)
module ContentCache

  def self.append_features(base) #:nodoc:
    super
    base.extend(ClassMethods)
    base.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    # Use this like you would ApplicationControlle.expires_page:
    # 
    #   expire_action_content('/blog')
    def expire_action_content(path)
      expire_fragment(/#{Regexp.escape(path[1..-1])}.*/)
    end
  end
  
  module ClassMethods
  
    # Documentation goes here.
    # Call it just like you would caches action.
    def caches_action_content(*actions)
      return unless perform_caching
      around_filter(ActionContentFilter.new(*actions))
    end
    
  end
end

class ActionContentFilter

  # These can only be strings.
  cattr_accessor :preserved_instance_variables
  @@preserved_instance_variables = ['@page_title', '@page_breadcrumbs']

  def action_url_to_id(controller, tag="content_only")  #:nodoc:
    '/'+controller.controller_path+'_'+tag
  end

  def initialize(*actions)  #:nodoc:
    @actions = actions
  end

  def before(controller)  #:nodoc:
    return unless @actions.include?(controller.action_name.intern) && controller.perform_caching
    return if controller.request.post?
    if cache = controller.read_fragment(action_url_to_id(controller))
      # Load preserved instance variables
      if template = controller.instance_variable_get('@template')
        for preserved_instance_variable in @@preserved_instance_variables
          if preserved_instance_variable_value = controller.read_fragment(action_url_to_id(controller,preserved_instance_variable.gsub('@','')))
            template.instance_variable_set(preserved_instance_variable, preserved_instance_variable_value)
          end
        end
      else
        logger.error('Template not found!')
      end
      old_logger_level = controller.logger.level
      begin
        # temporarily raise the logger level to fatal, otherwise the entirety of
        # the cached fragment is written to the logs (which get big real quick)
        controller.logger.level = Logger::FATAL
        
        # render the cached fragments
        controller.rendered_action_cache = true
        controller.render :text => cache, :layout => true
        
        # sweep the cache, call any necessary after filters
        controller.after_action
      ensure
        controller.logger.level = old_logger_level
      end
    end
  end
  
  def after(controller)  #:nodoc:
    return if !@actions.include?(controller.action_name.intern) || controller.rendered_action_cache
    template = controller.instance_variable_get('@template')
    if template
      # Save the action content to a fragment.
      content_for_layout = template.instance_variable_get('@content_for_layout')
      if content_for_layout
        controller.write_fragment(action_url_to_id(controller), content_for_layout)
      end
      
      # Save preserved instance variables
      if template = controller.instance_variable_get('@template')
        for preserved_instance_variable in @@preserved_instance_variables
          if preserved_instance_variable_value = template.instance_variable_get(preserved_instance_variable)
            controller.write_fragment(action_url_to_id(controller,preserved_instance_variable.gsub('@','')),preserved_instance_variable_value)
          end
        end
      else
        logger.error('Template not found!')
      end
      
    end
  end
end

class ActionController::Base #:nodoc:
  include ContentCache
end
