module Emittr
  class Emitter
    include Emittr::Events

    def initialize(max_listeners: nil)
      @max_listeners_value = max_listeners
    end
  end
end
