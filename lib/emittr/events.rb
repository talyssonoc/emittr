module Emittr
  module Events
    def self.included(klass)
      klass.__send__ :include, InstanceMethods
    end

    module InstanceMethods
      def on(event, &block)
        raise ArgumentError, 'required block not passed' unless block_given?

        listeners[event.to_sym] << ::Emittr::Callback.new(&block)
        self
      end

      def off(event, &block)
        return unless listeners.key? event

        if block_given?
          listeners[event].reject! { |l| l == block }
        else
          listeners.delete event
        end

        self
      end

      def once(event, &block)
        callback = ::Emittr::Callback.new &block

        off_block = Proc.new do |args|
          callback.call(*args)
          block_to_send = callback.wrapper || callback.callback

          off(event, &block_to_send)
        end

        callback.wrapper = off_block

        on(event, &off_block)
      end

      def emit(event, *payload)
        return unless listeners.key? event

        listeners[event].each do |l|
          l.call(*payload)
        end

        self
      end

      def listeners_for(event)
        listeners[event.to_sym].dup
      end

      private

      def listeners
        @listeners ||= Hash.new { |h,k| h[k] = [] }
      end
    end
  end
end
