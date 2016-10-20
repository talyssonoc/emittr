require 'spec_helper'

describe Emittr::Listeners do
  let(:emitter) { Emittr::Emitter.new }
  let(:listeners) { Emittr::Listeners.new emitter }

  describe '#add_listener' do
    it 'adds listener on passed event' do
      callback = ::Emittr::Callback.new { }
      listeners.add_listener :event, callback

      expect(listeners).to eq({ event: [callback] })
    end

    context "when trying to add a callback that isn't an Emittr::Callback" do
      it 'raises ArgumentError with proper message' do
        expect {
          callback = proc {}
          listeners.add_listener :event, callback
        }.to raise_error ArgumentError, 'must be an Emittr::Callback object'
      end
    end
  end

  describe '#for' do
    let(:callback) { ::Emittr::Callback.new { } }

    it 'returns a list of callbacks for passed event' do
      listeners.add_listener :event, callback

      expect(listeners.for(:event)).to eq [callback]
    end

    context 'when trying to add listeners via #for' do
      it "doesn't add new callbacks to the list" do
        expect {
          listeners.for(:event) << callback
        }.not_to change(listeners.for(:event), :count)
      end
    end
  end

  describe '#max_listeners' do
    let(:callback) { ::Emittr::Callback.new {} }
    let(:other_callback) { ::Emittr::Callback.new {} }

    context 'when adding new listeners when #max_listeners is set' do
      it "doesn't add new listeners when limit is reached" do
        listeners.max_listeners 1
        listeners.add_listener :max, callback

        expect {
          listeners.add_listener :max, other_callback rescue RuntimeError
        }.not_to change(listeners.for(:max), :count)
      end

      it 'raises MaxListenersLimit error when adding new listeners' do
        listeners.max_listeners 1
        listeners.add_listener :max, callback

        expect {
          listeners.add_listener :max, other_callback
        }.to raise_error RuntimeError, "can't add more listeners"
      end
    end

    context 'when trying to overwrite max_listeners value' do
      it 'raises RuntimeError' do
        listeners.max_listeners 1

        expect {
          listeners.max_listeners 2
        }.to raise_error RuntimeError, "can't overwrite max listeners value"
      end

      it "doesn't change max_listeners value" do
        listeners.max_listeners 1

        expect {
          listeners.max_listeners 2 rescue RuntimeError
        }.not_to change { listeners.max_listeners_value }
      end
    end
  end
end
