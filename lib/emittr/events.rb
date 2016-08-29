module Emittr
  module Events
    def self.included(klass)
      klass.__send__ :include, InstanceMethods
    end

    module InstanceMethods
      def on(event, &block)
        raise_no_block_error unless block_given?

        listeners[event.to_sym] << ::Emittr::Callback.new(&block)
        self
      end

      def off(event = nil, &block)
        unless event
          listeners.clear
          return self
        end

        if block_given?
          listeners[event].reject! { |l| l == block }
        else
          listeners.delete event
        end

        self
      end

      def once(event, &block)
        raise_no_block_error unless block_given?

        callback = ::Emittr::Callback.new(&block)

        off_block = proc do |args|
          callback.call(*args)
          block_to_send = callback.wrapper || callback.callback

          off(event, &block_to_send)
        end

        callback.wrapper = off_block

        on(event, &off_block)
      end

      def on_any(&block)
        raise_no_block_error unless block_given?
        on(:*, &block)
      end

      def off_any(&block)
        raise_no_block_error unless block_given?
        off(:*, &block)
      end

      def once_any(&block)
        raise_no_block_error unless block_given?
        once(:*, &block)
      end

      def emit(event, *payload)
        emit_any(event, *payload)

        return unless listeners.key? event

        listeners[event].each do |l|
          l.call(*payload)
        end

        self
      end

      def listeners_for(event)
        listeners[event.to_sym].dup
      end

      def listeners_for_any
        listeners[:*].dup
      end

      private

      def listeners
        @listeners ||= Hash.new { |h, k| h[k] = [] }
      end

      def emit_any(event, *payload)
        any_listeners = listeners[:*]
        any_listeners.each { |l| l.call(event, *payload) } if any_listeners.any?
      end

      def raise_no_block_error
        raise ArgumentError, 'required block not passed'
      end
    end
  end
end
