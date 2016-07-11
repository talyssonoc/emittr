require 'spec_helper'

describe Emittr::Callback do
  let(:callback) { Proc.new {} }

  it { is_expected.to respond_to :wrapper }

  describe '#new' do
    it 'sets callback' do
      cb = Emittr::Callback.new &callback
      expect(cb.callback).to eq callback
    end
  end

  describe '#call' do
    it 'calls #call on callback' do
      expect(callback).to receive(:call)
      cb = Emittr::Callback.new &callback
      cb.call
    end
  end

  describe '#==' do
    context 'when same callbacks' do
      it 'returns true' do
        cb = Emittr::Callback.new &callback
        second_cb = Emittr::Callback.new &callback

        expect(cb == second_cb).to be true
      end
    end

    context 'when different callback but wrapper is same' do
      it 'returns true' do
        diff_callback = Proc.new {}
        cb = Emittr::Callback.new &callback
        second_cb = Emittr::Callback.new &diff_callback
        second_cb.wrapper = cb

        expect(cb == second_cb).to be true
      end
    end

    context 'when an invalid param is provided' do
      it 'raises ArgumentError' do
        cb = Emittr::Callback.new &callback
        expect {
          cb == :test
        }.to raise_error ArgumentError, 'must be an instance of Emittr::Callback'
      end
    end
  end
end
