module CollectiveIdea
  module WithAction
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def with_action
        responder = ActionResponder.new(params)
        yield responder
        responder.respond
      end
    end
    
    class ActionResponder
      def initialize(params)
        @params = params
        @order, @responses = [], {}
      end
      
      def respond
        action = @order.detect {|a| !@params[a].blank? || !@params["#{a}.x"].blank? }
        action ||= @order.include?(:any) ? :any : @order.first
        @responses[action].call if @responses[action]
      end
      
      def any(&block)
        method_missing(:any) do
          # reset
          @order, @responses = [], {}
          returning block.call do
            respond
          end
        end
      end
      
      def method_missing(action, &block)
        @order << action
        @responses[action] = block
      end
    end
    
  end
end
