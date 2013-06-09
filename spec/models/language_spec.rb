require 'spec_helper'

describe Language do
  let(:c) do
    Language.
      new(name: 'C',
          compiler: '/usr/bin/gcc -x c -lm %s -o %s',
          description: 'GCC version 4.4.3')
  end

  let(:ruby) do
    Language.
      new(name: 'Ruby',
          interpreter: '/opt/ruby/bin/ruby',
          memory: 60000,
          time: 2,
          description: 'ruby 2.0.0dev',
          processes: 3)
  end

  describe 'memory' do
    it 'is 0 default' do
      ruby.memory.should == 60000
    end
  end
end
