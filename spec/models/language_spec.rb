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
        allow(ruby).to receive(:exe).with('program').and_return('program path')
        expect(ruby.compile 'program').to eq('program path')
      end
    end
    context 'when compiled' do
      before do
        allow(c).to receive(:command).with(program).and_return('command')
      end
      it 'returns compiled program path' do
        allow(Kernel).to receive(:system).with('command').and_return(true)
        c.compile(program)
      end
      it 'returns compiled program path' do
        allow(Kernel).to receive(:system).with('command').and_return(true)
        expect(c.compile program).to eq('/program/path/exe')
      end
      it 'raises error if compilation failed' do
        allow(Kernel).to receive(:system).with('command').and_return(false)
        expect { c.compile(program) }.to raise_error
      end
    end
  end

  describe "#command" do
    describe 'for c' do
      it 'is c compiler with arguments' do
        expect(c.command program).to eq('/usr/bin/gcc -x c -lm /program/path/name.c -o /program/path/exe 2> /tmp/error.log')
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
        expect(java.command program).to eq("/usr/bin/gcj /program/full/Solution.java -o /program/full/Solution --main=Solution -lm 2> /tmp/error.log")
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
        expect(go.command program).to eq("/opt/go/bin build -o /program/full/solve /program/full/solve.go 2> /tmp/error.log")
      end
    end
  end

  describe '#invalid?' do
    it 'is true if compiler neither interpreter is given' do
      expect(english).to be_invalid
    end
  end

  describe '#exe' do
    context 'when interpreted' do
      it 'is interpreter with program as a argument' do
        allow(program).to receive(:fullname).and_return '/program/full/name.rb'
        expect(ruby.exe program).to eq('/opt/ruby/bin/ruby /program/full/name.rb')
      end
    end
    context 'when compiled' do
      it 'is executable program path' do
        expect(c.exe program).to eq('/program/path/exe')
      end
    end
  end

  describe 'memory' do
    it 'is 0 default' do
      expect(c.memory).to eq(0)
    end
    it 'is memory size' do
      expect(ruby.memory).to eq(60000)
    end
  end

  describe 'time' do
    it 'is 0 default' do
      expect(c.time).to eq(0)
    end
    it 'is memory size' do
      expect(ruby.time).to eq(2)
    end
  end

  describe 'processes' do
    it 'is 0 default' do
      expect(c.processes).to eq(0)
    end
    it 'is memory size' do
      expect(ruby.processes).to eq(3)
    end
  end

  describe 'extension' do
    it 'is lowercase of name by default' do
      expect(c.extension).to eq('.c')
    end
    it 'is given extension' do
      expect(ruby.extension).to eq('.rb')
    end
  end

  describe 'compiled?' do
    it 'is true if compiler is not blank' do
      expect(c).to be_compiled
    end
    it 'is false if language is compiled' do
      expect(ruby).not_to be_compiled
    end
  end
end
