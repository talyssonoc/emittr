module Emittr
  module Events
    def self.included(klass)
      klass.__send__ :include, InstanceMethods
    end

    module InstanceMethods
      def on(event, &callback)
        raise ArgumentError, 'required block not passed' unless block_given?

        listeners[event.to_sym] << ::Emittr::Callback.new(&callback)
        self
      end

      def off(event, &callback)
        return unless listeners.key? event

        if block_given?
          listeners[event].reject! { |l| l == callback }
        else
          listeners.delete event
        end

        self
      end

      def emit(event, *payload)
        return unless listeners.key? event

        listeners[event].each do |l|
          l.call(*payload)
        end

        self
      end

      private

      def listeners
        @listeners ||= Hash.new { |h,k| h[k] = [] }
      end
    end
  end
end
