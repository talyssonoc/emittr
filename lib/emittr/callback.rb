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
      callback == cb || wrapper == cb
    end
  end
end
