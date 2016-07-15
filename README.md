# Emittr

Emittr is a event emitter for Ruby.

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

```ruby
emitter = Emittr::Emitter.new
```

## Add events

### #on(event, callback)

Call `callback` when `event` is emitted.

### #once(event, callback)

Call `callback` when `event` is emitted for the first time, then removes `callback` from `callbacks` list.

## Remove events

### #off(event, callback)

Remove `callback` from `event` callbacks list.

### #off(event)

Removes all callbacks for `event`.

### #off

Removes all callbacks for all events.

## Global events

### #on_any(callback)

Call `callback` whenever an event is emitted.

### #off_any(callback)

Remove `callback` from list to be run after any event is emitted.

### #once_any(callback)

Call `callback` the first time any event is emitted then removes it from list.

## Emitting events

### #emit(type, args)

Emit an `event` with `args` as params.

## Retrieving added events

### #listeners_for(event)

Return all callbacks for `event`. Callbacks added with `#on_any` or `#once_any` wil not be included.

### #listeners_for_any

Return all callbacks added with `#on_any` or `#once_any`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

