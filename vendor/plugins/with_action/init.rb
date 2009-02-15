require 'with_action'

ActionController::Base.class_eval do
  include CollectiveIdea::WithAction
end
