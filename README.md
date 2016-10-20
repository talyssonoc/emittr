# Emittr

Emittr is a event emitter for Ruby.

[![Build Status](https://travis-ci.org/talyssonoc/emittr.svg?branch=master)](https://travis-ci.org/talyssonoc/emittr) [![Coverage Status](https://coveralls.io/repos/github/talyssonoc/emittr/badge.svg?branch=master)](https://coveralls.io/github/talyssonoc/emittr?branch=master)

Installation
------------

Add this line to your Gemfile:

```ruby
gem 'emittr'
```

Or install it yourself as:

    $ gem install emittr

Usage
-----

Emittr can be used in two ways. You can just create an `Emittr::Emitter` instance and use it to emit and listen to events, like this:

```ruby
emitter = Emittr::Emitter.new

emitter.on :user_connected do |user_name|
  puts "Hello, #{user_name}"
end

emitter.emit :user_connected, 'Mr. Anderson'
```

Or you can include the `Emittr::Events` module into an existent class to make it an event emitter:

```ruby
class Server
  include Emittr::Events

  def initialize
    on(:user_connected) do |user_data|
      handle_new_connection(user_data)
    end
  end

  def handle_new_connection(user_data)
    # do something clever here
  end
end

server = Server.new

server.emit :user_connected, { name: 'Somebody', ip: '127.0.0.1' }
```

Config
------

### Limiting listeners

You can set a limit to prevent adding listeners by using:
```ruby
class Server
  include Emittr::Events

  max_listeners 20
end
```
or

```ruby
emitter = Emittr::Emitter.new max_listeners: 20
```

This value can be get later from `#max_listeners_value`.

**NOTE:** You can't overwrite `#max_listeners` value. If you try to do it, a `RuntimeError` will be raised.

## Add event listeners

* `#on(event, callback)` - Call `callback` when `event` is emitted.

* `#once(event, callback)` - Call `callback` when `event` is emitted for the
first time, then the `callback` is removed from the listeners list of the given `event`.

* `#on_any(callback)` - Call `callback` whenever an event is emitted.

* `#once_any(callback)` - Call `callback` the first time any event is emitted then removes it from list.

* `#on_many_times(event, times, callback)` - Acts like `#once`, but the listener
will be removed from the list only after emitting the event as many times as
provided. It accepts only positive Integer number as argument.

## Remove event listeners

* `#off(event, callback)` - Remove `callback` from `event` callbacks list.

* `#off(event)` - Removes all callbacks for `event`.

* `#off` - Removes all callbacks for all events.

* `#off_any(callback)` - Remove `callback` from list to be run after any event is emitted.

## Emitting events

* `#emit(type, *args)` - Emit an `event` with all passed `args` as params.

## Retrieving added events

* `#listeners_for(event)` - Return all callbacks for `event`. Callbacks added
with `#on_any` or `#once_any` will not be included.

* `#listeners_for_any` - Return all callbacks added with `#on_any` or `#once_any`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
