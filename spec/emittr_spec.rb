require 'spec_helper'

describe Emittr do
  let(:emitter) { Emittr::Emitter.new }

  shared_examples_for 'no_block_passed' do |emitter_method|
    context 'when no block is passed' do
      it 'should throw an argument error' do
        expect {
          emitter.send(emitter_method, :no_block_test)
        }.to raise_error ArgumentError
      end
    end
  end

  describe '#on' do
    include_examples 'no_block_passed', :on

    it 'adds callback to listeners list' do
      callback = proc {}
      callback_inst = Emittr::Callback.new(&callback)

      allow(Emittr::Callback).to receive(:new).and_return(callback_inst)

      emitter.on :on_test, &callback

      listeners = emitter.listeners_for(:on_test)
      expect(listeners).to eq [callback_inst]
    end
  end

  describe '#off' do
    describe 'without callback' do
      context 'when there are no listeners to the given event' do
        it "doesn't throw an error" do
          expect {
            emitter.off :off_test
          }.to_not raise_error
        end
      end

      context 'when there are listeners to given event' do
        it 'removes all listeners for event' do
          callback = proc {}
          allow(callback).to receive(:call)
          emitter.on :off_test, &callback

          emitter.off :off_test
          emitter.emit :off_test

          listeners = emitter.listeners_for(:off_test)
          expect(listeners).to be_empty
          expect(callback).not_to have_received(:call)
        end
      end
    end

    describe 'with callback' do
      context 'when there are no listeners to the given event' do
        it "doesn't throw an error" do
          expect {
            emitter.off :off_test
          }.to_not raise_error
        end
      end

      context 'when there are listeners to given event' do
        it 'removes listeners for event' do
          callback = proc {}
          allow(callback).to receive(:call)
          emitter.on :off_test, &callback

          emitter.off :off_test, &callback
          emitter.emit :off_test

          listeners = emitter.listeners_for(:off_test)
          expect(listeners).to be_empty
          expect(callback).not_to have_received(:call)
        end
      end
    end

    describe 'when no event is passed' do
      let(:block) { proc {} }

      it 'empty listeners list' do
        emitter.on :first_clear_test, &block
        emitter.on :second_clear_test, &block

        expect(emitter.send(:listeners).count).to eq 2
        emitter.off
        expect(emitter.send(:listeners).count).to eq 0
      end
    end
  end

  describe '#once' do
    include_examples 'no_block_passed', :once

    let(:block) { proc {} }

    it 'adds listener to listeners list' do
      expect {
        emitter.once :once_test, &block
      }.to change { emitter.listeners_for(:once_test).count }.by 1
    end

    context 'when event is emitted' do
      before { emitter.once :once_test, &block }

      it 'calls callback only once' do
        expect(block).to receive(:call).once
        2.times { emitter.emit :once_test }
      end

      it 'removes listener from listeners list when emitted' do
        emitter.emit :once_test
        expect(emitter.listeners_for(:once_test)).to be_empty
      end
    end
  end

  describe '#on_any' do
    include_examples 'no_block_passed', :on_any

    let(:any_block) { proc {} }

    context 'when listeners for a specific event are set' do
      it 'calls #on_any blocks' do
        block = proc {}

        emitter.on_any(&any_block)

        emitter.on :first_any_test, &block
        emitter.on :second_any_test, &block

        expect(any_block).to receive(:call).with(:first_any_test).twice
        expect(any_block).to receive(:call).with(:second_any_test).twice

        2.times { emitter.emit :first_any_test }
        2.times { emitter.emit :second_any_test }
      end
    end

    context 'when no events are set' do
      it 'calls #on_any blocks' do
        emitter.on_any(&any_block)

        expect(any_block).to receive(:call).with(:on_any_test).twice

        2.times { emitter.emit :on_any_test }
      end
    end
  end

  describe '#off_any' do
    include_examples 'no_block_passed', :off_any

    let(:block) { proc {} }

    it 'removes listener from #any list' do
      block_for_on = proc {}

      emitter.on :off_any_test, &block_for_on

      emitter.on_any(&block)

      expect(block).to receive(:call).with(:off_any_test)
      emitter.emit :off_any_test
      expect(emitter.listeners_for_any).not_to be_empty

      emitter.off_any(&block)

      expect(block).not_to receive(:call).with(:off_any_test)
      emitter.emit :off_any_test
      expect(emitter.listeners_for_any).to be_empty
    end

    it "doesn't call block" do
      emitter.on(:off_any_test) { proc {} }

      emitter.on_any(&block)
      expect(block).to receive(:call)
      emitter.emit :off_any_test

      emitter.off_any(&block)
      expect(block).not_to receive(:call)
      emitter.emit :off_any_test
    end
  end

  describe '#once_any' do
    include_examples 'no_block_passed', :once_any

    let(:block)    { proc {} }
    let(:on_block) { proc {} }

    it 'adds listener to #any listeners list' do
      expect {
        emitter.once_any(&block)
      }.to change(emitter.send(:listeners)[:*], :count).by 1
    end

    context 'when any event is emitted' do
      it 'calls block added to any list only once' do
        emitter.once_any(&block)
        emitter.on :once_any_test, &on_block

        expect(block).to receive(:call).once
        2.times { emitter.emit :once_any_test }
      end

      it 'removes listener from listeners list after emitted' do
        emitter.once_any(&block)
        emitter.on :once_any_test, &on_block

        emitter.emit :once_any_test

        expect(emitter.listeners_for_any).to be_empty
      end
    end
  end

  describe '#on_many_times' do
    include_examples 'no_block_passed', :on_many_times

    let(:callback) { proc {} }

    it "raises an ArgumentError when first param isn't an Integer" do
      times = 'A'

      expect {
        emitter.on_many_times :many, times, &callback
      }.to raise_error ArgumentError, "#{times} must be an integer"
    end

    it "raises an ArgumentError when first param is a negative number" do
      times = -1

      expect {
        emitter.on_many_times :many, times, &callback
      }.to raise_error ArgumentError, "#{times} can't be negative"
    end

    it 'calls callback as many times as provided' do
      emitter.on_many_times :many, 3, &callback

      expect(callback).to receive(:call).exactly(3).times
      4.times { emitter.emit :many }
    end

    it 'removes listener when reaching how many times the callback can run' do
      emitter.on_many_times :many, 1, &callback
      2.times { emitter.emit :many }

      expect(emitter.listeners_for(:many)).to be_empty
    end
  end

  describe '#emit' do
    context "when events doesn't have payload" do
      it 'calls the callbacks' do
        callback = proc {}
        callback_2 = proc {}
        allow(callback).to receive(:call)
        allow(callback_2).to receive(:call)
        emitter.on :emit_test, &callback
        emitter.on :emit_test, &callback_2

        emitter.emit :emit_test

        expect(callback).to have_received(:call)
        expect(callback_2).to have_received(:call)
      end
    end

    context 'when events have payload' do
      it 'calls the callbacks with the payload' do
        callback = proc {}
        callback_2 = proc { |a, b| }
        allow(callback).to receive(:call)
        allow(callback_2).to receive(:call)
        emitter.on :emit_test, &callback
        emitter.on :emit_test, &callback_2

        emitter.emit :emit_test, 'A', 'B'

        expect(callback).to have_received(:call).with('A', 'B')
        expect(callback_2).to have_received(:call).with('A', 'B')
      end
    end

    context 'when there are no listeners to given event' do
      it "doesn't throw an error" do
        expect {
          emitter.emit :emit_test
        }.not_to raise_error
      end
    end
  end

  describe '#listeners_for' do
    let(:block) { proc {} }

    it 'retrieve listeners for provided event' do
      event = :listener
      emitter.on event, &block
      expect(emitter.listeners_for(event)).to eq [block]
    end

    it "can't be changed externally" do
      event = :listener
      emitter.on event, &block

      expect {
        emitter.listeners_for(event) << proc {}
      }.not_to change { emitter.listeners_for(event).count }
    end
  end

  describe '#listeners_for_any' do
    let(:block) { proc {} }

    it 'retrieve listeners for "any" list' do
      emitter.on_any(&block)
      expect(emitter.listeners_for_any).to eq [block]
    end

    it "can't be changed externally" do
      emitter.on_any(&block)

      expect {
        emitter.listeners_for_any << proc {}
      }.not_to change { emitter.listeners_for_any.count }
    end
  end
end
