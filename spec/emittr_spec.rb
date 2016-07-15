require 'spec_helper'

describe Emittr do
  let(:emitter) { Emittr::Emitter.new }

  describe '#on' do
    it 'should add callback to listeners list' do
      callback = Proc.new {}
      callback_inst = Emittr::Callback.new(&callback)

      allow(Emittr::Callback).to receive(:new).and_return(callback_inst)

      emitter.on :on_test, &callback

      listeners = emitter.listeners_for(:on_test)
      expect(listeners).to eq [callback_inst]
    end

    context 'when no block is passed' do
      it 'should throw an argument error' do
        expect {
          emitter.on :on_test
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#off' do
    describe 'without callback' do
      context 'when there are no listeners to the given event' do
        it 'should not throw an error' do
          expect {
            emitter.off :off_test
          }.to_not raise_error
        end
      end

      context 'when there are listeners to given event' do
        it 'should remove all listeners for event' do
          callback = Proc.new {}
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
        it 'should not throw an error' do
          expect {
            emitter.off :off_test
          }.to_not raise_error
        end
      end

      context 'when there are listeners to given event' do
        it 'should remove listeners for event' do
          callback = Proc.new {}
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
  end

  describe '#once' do
    let(:block) { Proc.new {} }

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

  describe '#emit' do
    context "when events don't have payload" do
      it 'should call the callbacks' do
        callback = Proc.new {}
        callback_2 = Proc.new {}
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
      it 'should call the callbacks with the payload' do
        callback = Proc.new {}
        callback_2 = Proc.new { |a, b| }
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
      it 'should not throw an error' do
        expect {
          emitter.emit :emit_test
        }.not_to raise_error
      end
    end
  end

  describe '#listeners_for' do
    let(:block) { Proc.new {} }

    it 'retrieve listeners for provided event' do
      event = :listener
      emitter.on event, &block
      expect( emitter.listeners_for(event) ).to eq [block]
    end

    it "can't be changed externally" do
      event = :listener
      emitter.on event, &block

      expect {
        emitter.listeners_for(event) << Proc.new {}
      }.not_to change { emitter.listeners_for(event).count }
    end
  end
end
