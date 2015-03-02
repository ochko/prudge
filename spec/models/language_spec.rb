require 'spec_helper'

describe Language do
  let(:c) {
    Language.
      new(name: 'C',
          compiler: '/usr/bin/gcc -x c -lm %{source} -o %{output}',
          description: 'GCC') }
  let(:go) {
    Language.
      new(name: 'Go',
          compiler: '/opt/go/bin build -o %{output} %{source}',
          description: 'golang') }
  let(:java) {
    Language.
      new(name: 'Java',
          compiler: '/usr/bin/gcj %{source} -o %{output} --main=%{basename} -lm',
          memory: 14000,
          description: 'gcj') }
  let(:ruby) {
    Language.
      new(name: 'Ruby',
          extension: '.rb',
          interpreter: '/opt/ruby/bin/ruby',
          memory: 60000,
          time: 2,
          description: 'ruby 2.0.0dev',
          processes: 3) }

  let(:english) { Language.new(name: 'English') }

  let(:program) {
    double('program',
           :fullname => '/program/path/name.c',
           :path => '/program/path/exe',
           :basename => 'name',
           :error => '/tmp/error.log' ) }

  describe '#compile' do
    context 'when invalid' do
      it 'raises compile error' do
        expect {english.compile 'program' }.to raise_error
      end
    end
    context 'when interpreted' do
      it 'returns executable path' do
        ruby.stub(:exe, 'program') {'program path'}
        ruby.compile('program').should == 'program path'
      end
    end
    context 'when compiled' do
      before do
        c.stub(:command, program) {'command'}
      end
      it 'returns compiled program path' do
        Kernel.should_receive(:system).with('command') { true }
        c.compile(program)
      end
      it 'returns compiled program path' do
        Kernel.should_receive(:system).with('command') { true }
        c.compile(program).should == '/program/path/exe'
      end
      it 'raises error if compilation failed' do
        Kernel.should_receive(:system).with('command') { false }
        expect { c.compile(program) }.to raise_error
      end
    end
  end

  describe "#command" do
    describe 'for c' do
      it 'is c compiler with arguments' do
        c.command(program).should == '/usr/bin/gcc -x c -lm /program/path/name.c -o /program/path/exe 2> /tmp/error.log'
      end
    end

    describe 'for java' do
      let(:program) {
        double('program',
               :fullname => '/program/full/Solution.java',
               :path => '/program/full/Solution',
               :basename => 'Solution',
               :error => '/tmp/error.log' ) }

      it 'is java compiler with arguments' do
        java.command(program).should == "/usr/bin/gcj /program/full/Solution.java -o /program/full/Solution --main=Solution -lm 2> /tmp/error.log"
      end
    end

    describe 'for go' do
      let(:program) {
        double('program',
               :fullname => '/program/full/solve.go',
               :path => '/program/full/solve',
               :basename => 'solve',
               :error => '/tmp/error.log' ) }

      it 'is go compiler with arguments' do
        go.command(program).should == "/opt/go/bin build -o /program/full/solve /program/full/solve.go 2> /tmp/error.log"
      end
    end
  end

  describe '#invalid?' do
    it 'is true if compiler neither interpreter is given' do
      english.should be_invalid
    end
  end

  describe '#exe' do
    context 'when interpreted' do
      it 'is interpreter with program as a argument' do
        program.stub(:fullname) { '/program/full/name.rb' }
        ruby.exe(program).should == '/opt/ruby/bin/ruby /program/full/name.rb'
      end
    end
    context 'when compiled' do
      it 'is executable program path' do
        c.exe(program).should == '/program/path/exe'
      end
    end
  end

  describe 'memory' do
    it 'is 0 default' do
      c.memory.should == 0
    end
    it 'is memory size' do
      ruby.memory.should == 60000
    end
  end

  describe 'time' do
    it 'is 0 default' do
      c.time.should == 0
    end
    it 'is memory size' do
      ruby.time.should == 2
    end
  end

  describe 'processes' do
    it 'is 0 default' do
      c.processes.should == 0
    end
    it 'is memory size' do
      ruby.processes.should == 3
    end
  end

  describe 'extension' do
    it 'is lowercase of name by default' do
      c.extension.should == '.c'
    end
    it 'is given extension' do
      ruby.extension.should == '.rb'
    end
  end

  describe 'compiled?' do
    it 'is true if compiler is not blank' do
      c.should be_compiled
    end
    it 'is false if language is compiled' do
      ruby.should_not be_compiled
    end
  end
end
