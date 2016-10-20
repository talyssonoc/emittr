module Emittr
  class Listeners < Hash
    attr_reader :max_listeners_value

    def initialize(emitter)
      @max_listeners_value = emitter.instance_variable_get(:@max_listeners_value)
      super() { |h, k| h[k] = [] }
    end

    def max_listeners(limit)
      raise RuntimeError, "can't overwrite max listeners value" if @max_listeners_value

      @max_listeners_value = limit
    end

    def add_listener(event, listener)
      raise ArgumentError, "must be an Emittr::Callback object" unless listener.is_a? ::Emittr::Callback
      raise RuntimeError, "can't add more listeners" if unable_to_add_listerners?

      self[event.to_sym] << listener
    end

    def for(event)
      self[event.to_sym].dup
    end

    private

    def unable_to_add_listerners?
      @max_listeners_value && self.values.flatten.count >= @max_listeners_value
    end
  end
end
