module Emittr
  class Callback
    attr_accessor :wrapper, :callback

    def initialize(&callback)
      @callback = callback
    end

    def call(*args)
      callback.call(*args)
    end

    def ==(cb)
      raise ArgumentError, 'must be an instance of Emittr::Callback' unless cb.is_a? Callback
      cb.callback == callback || self.equal?(cb.wrapper)
    end
  end
end
