describe "JudgeAbility" do
  let(:judge) { Fabricate :judge }

  subject(:ability) {JudgeAbility.new(judge)}

  describe "contest" do
    let(:contest) { Fabricate.build(:contest) }

    it{ should be_able_to(:manage, contest) }
  end

  describe "problem" do
    let(:problem) { Fabricate.build(:problem) }

    it{ should be_able_to(:manage, problem) }
    it{ should be_able_to(:check, problem) }
    it{ should be_able_to(:approve, problem) }
  end

  describe "test" do
    let(:test) { Fabricate.build(:problem_test) }

    it{ should be_able_to(:manage, test) }
  end

  describe "solution" do
    let(:solution) { Fabricate.build(:solution) }

    it{ should be_able_to(:update, solution) }
    it{ should be_able_to(:check, solution) }
  end

  describe "result" do
    it{ should be_able_to(:read, Fabricate.build(:result, hidden: true)) }
    it{ should be_able_to(:read, Fabricate.build(:result, hidden: false)) }
  end
end
