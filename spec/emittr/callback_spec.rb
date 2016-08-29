require 'spec_helper'

describe Emittr::Callback do
  let(:callback) { proc {} }

  it { is_expected.to respond_to :wrapper }

  describe '#new' do
    it 'sets callback' do
      cb = Emittr::Callback.new(&callback)
      expect(cb.callback).to eq callback
    end
  end

  describe '#call' do
    it 'calls #call on callback' do
      expect(callback).to receive(:call)
      cb = Emittr::Callback.new(&callback)
      cb.call
    end
  end

  describe '#==' do
    context 'when same callback is passed' do
      it 'returns true' do
        cb = Emittr::Callback.new(&callback)
        expect(cb == callback).to be true
      end
    end

    context 'when different callback is passed' do
      context 'and wrapper is also different' do
        it 'returns false' do
          wrapper_callback = proc {}
          unset_callback = proc {}

          cb = Emittr::Callback.new(&callback)
          cb.wrapper = wrapper_callback

          expect(cb == unset_callback).to be false
        end
      end

      context 'and wrapper is the same' do
        it 'returns true' do
          diff_callback = proc {}
          cb = Emittr::Callback.new(&callback)
          cb.wrapper = diff_callback

          expect(cb == diff_callback).to be true
        end
      end
    end
  end
end
