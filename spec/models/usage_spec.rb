require 'spec_helper'

describe Usage do
  context "empty string" do
    let(:usage) {Usage.new('')}

    it 'is unknown' do
      expect(usage.state).to eq(0)
      expect(usage.time).to eq(nil)
      expect(usage.memory).to eq(nil)
    end
  end

  context "null" do
    let(:usage) {Usage.new(nil)}

    it 'is unknown' do
      expect(usage.state).to eq(0)
      expect(usage.time).to eq(nil)
      expect(usage.memory).to eq(nil)
    end
  end

  context "exited with non-zero status" do
    let(:usage) {Usage.new(<<-___
Command exited with non-zero status (1)
elapsed time: 1 seconds
memory usage: 1424 kbytes
cpu usage: 0.000 seconds
___
                           )}

    it 'is non-zero' do
      expect(usage.state).to eq(2**5)
      expect(usage.time).to eq(0)
      expect(usage.memory).to eq(1424)
    end
  end

  context "memory limit exceeded" do
    let(:usage) {Usage.new(<<-___
Memory Limit Exceeded
elapsed time: 0 seconds
memory usage: 32884 kbytes
cpu usage: 0.416 seconds
___
                           )}

    it 'is non-zero' do
      expect(usage.state).to eq(4)
      expect(usage.time).to eq(416)
      expect(usage.memory).to eq(32884)
    end
  end

  context "time limit exceeded" do
    let(:usage) {Usage.new(<<-___
Time Limit Exceeded
elapsed time: 2 seconds
memory usage: 1480 kbytes
cpu usage: 1.000 seconds
___
                           )}

    it 'is time limit' do
      expect(usage.state).to eq(2)
      expect(usage.time).to eq(1000)
      expect(usage.memory).to eq(1480)
    end
  end

  context "wall time limit exceeded" do
    let(:usage) {Usage.new(<<-___
Time Limit Exceeded
elapsed time: 3 seconds
memory usage: 1424 kbytes
cpu usage: 0.000 seconds
___
                           )}

    it 'is time limit' do
      expect(usage.state).to eq(2)
      expect(usage.time).to eq(0)
      expect(usage.memory).to eq(1424)
    end
  end

  context "OK" do
    let(:usage) {Usage.new(<<-___
OK
elapsed time: 1 seconds
memory usage: 64 kbytes
cpu usage: 0.010 seconds
___
                           )}

    it 'is ok' do
      expect(usage.state).to eq(1)
      expect(usage.time).to eq(10)
      expect(usage.memory).to eq(64)
    end
  end

end
