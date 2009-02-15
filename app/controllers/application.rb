require 'authenticated_system'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include SslRequirement

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_contest_session_id'

  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    options = default_options.merge options

    pages = Paginator.new self, collection.size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end

  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.
    merge!(
           :default => "%Y/%m/%d %H:%M",
           :date_time12 => "%Y/%m/%d %I:%M%p",
           :date_time24 => "%Y/%m/%d %H:%M",
           :date_only => "%Y-%m-%d",
           :time_only => "%H:%M",
           :short => "%y/%m/%d %H:%M",
           :shortest => "%m/%d %H:%M"
           )
  ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.
    merge!(
           :default => "%Y/%m/%d %H:%M",
           :date_time12 => "%Y/%m/%d %I:%M%p",
           :date_time24 => "%Y/%m/%d %H:%M",
           :date_only => "%Y-%m-%d",
           :time_only => "%H:%M",
           :short => "%y/%m/%d %H:%M"
           )
  protected
  def normalize_tags(tagged)
    tags = tagged.tags
    tags.sub!(',',' ')
    tags.strip!
    tagged.update_attribute('tags', ' ' + tags + ' ')
  end

  def is_admin?
    if current_user.roles.map{ |role| role.title.downcase}.include? 'admin'
      return true
    end
    return false
  end

  def is_judge?
    if current_user.roles.map{ |role| role.title.downcase}.include? 'judge'
      return true
    end
    return false
  end
end
