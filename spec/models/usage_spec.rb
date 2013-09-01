require 'spec_helper'

describe Usage do
  context "empty string" do
    let(:usage) {Usage.new('')}

    it 'is unknown' do
      usage.state.should == 0
      usage.time.should == nil
      usage.memory.should == nil
    end
  end

  context "null" do
    let(:usage) {Usage.new(nil)}

    it 'is unknown' do
      usage.state.should == 0
      usage.time.should == nil
      usage.memory.should == nil
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
      usage.state.should == 2**5
      usage.time.should == 0
      usage.memory.should == 1424
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
      usage.state.should == 4
      usage.time.should == 416
      usage.memory.should == 32884
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
      usage.state.should == 2
      usage.time.should == 1000
      usage.memory.should == 1480
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
      usage.state.should == 2
      usage.time.should == 0
      usage.memory.should == 1424
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
      usage.state.should == 1
      usage.time.should == 10
      usage.memory.should == 64
    end
  end

end
