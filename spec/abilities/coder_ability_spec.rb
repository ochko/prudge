describe "CoderAbility" do
  let(:coder) { Fabricate :coder }
  let(:contest) { Fabricate.build(:contest) }

  subject(:ability) {CoderAbility.new(coder)}

  describe "contest" do
    it{ should be_able_to(:read, contest) }
    it{ should_not be_able_to(:update, contest) }
    it{ should_not be_able_to(:delete, contest) }
    it{ should_not be_able_to(:create, contest) }
  end

  describe "problem" do
    it{ should be_able_to(:create, Problem) }

    context "not owned by coder & not published" do
      let(:problem) { Fabricate.build(:problem, contest: Fabricate.build(:upcoming_contest)) }
      let(:hidden_test) { Fabricate.build :problem_test, hidden: true, problem: problem }
      let(:visible_test) { Fabricate.build :problem_test, hidden: false, problem: problem }

      it{ should_not be_able_to(:read, problem) }
      it{ should_not be_able_to(:update, problem) }
      it{ should_not be_able_to(:delete, problem) }

      it{ should_not be_able_to(:read, visible_test) }
      it{ should_not be_able_to(:read, hidden_test) }
      it{ should_not be_able_to(:create, hidden_test) }
      it{ should_not be_able_to(:update, hidden_test) }
      it{ should_not be_able_to(:destroy, hidden_test) }
    end

    context "not owned by coder & published" do
      let(:problem) { Fabricate.build(:problem, contest: Fabricate.build(:ongoing_contest)) }
      let(:hidden_test) { Fabricate.build :problem_test, hidden: true, problem: problem }
      let(:visible_test) { Fabricate.build :problem_test, hidden: false, problem: problem }

      it{ should be_able_to(:read, problem) }
      it{ should_not be_able_to(:update, problem) }
      it{ should_not be_able_to(:delete, problem) }

      it{ should be_able_to(:read, visible_test) }
      it{ should_not be_able_to(:read, hidden_test) }
      it{ should_not be_able_to(:create, hidden_test) }
      it{ should_not be_able_to(:update, hidden_test) }
      it{ should_not be_able_to(:destroy, hidden_test) }
    end

    context "owned by coder & not published" do
      let(:problem) { Fabricate.build(:problem, user: coder) }
      let(:hidden_test) { Fabricate.build :problem_test, hidden: true, problem: problem }
      let(:visible_test) { Fabricate.build :problem_test, hidden: false, problem: problem }

      it{ should be_able_to(:read, problem) }
      it{ should be_able_to(:update, problem) }
      it{ should be_able_to(:destroy, problem) }

      it{ should be_able_to(:read, visible_test) }
      it{ should be_able_to(:read, hidden_test) }
      it{ should be_able_to(:create, hidden_test) }
      it{ should be_able_to(:update, hidden_test) }
      it{ should be_able_to(:destroy, hidden_test) }
    end

    context "owned by coder & published" do
      let(:problem) { Fabricate.build(:problem, user: coder, contest: Fabricate.build(:ongoing_contest)) }
      let(:hidden_test) { Fabricate.build :problem_test, hidden: true, problem: problem }
      let(:visible_test) { Fabricate.build :problem_test, hidden: false, problem: problem }

      it{ should be_able_to(:read, problem) }
      it{ should_not be_able_to(:destroy, problem) }
      it{ should_not be_able_to(:update, problem) }

      it{ should be_able_to(:read, visible_test) }
      it{ should be_able_to(:read, hidden_test) }
      it{ should_not be_able_to(:create, hidden_test) }
      it{ should_not be_able_to(:update, hidden_test) }
      it{ should_not be_able_to(:destroy, hidden_test) }
    end

    context "owned by coder & solved" do
      let(:problem) { Fabricate.build(:problem, user: coder, contest: Fabricate.build(:finished_contest)) }
      let(:hidden_test) { Fabricate.build :problem_test, hidden: true, problem: problem }
      let(:visible_test) { Fabricate.build :problem_test, hidden: false, problem: problem }

      before do
        Fabricate.build(:solution, problem: problem)
      end
      it{ should be_able_to(:read, problem) }
      it{ should_not be_able_to(:destroy, problem) }
      it{ should_not be_able_to(:update, problem) }

      it{ should be_able_to(:read, visible_test) }
      it{ should be_able_to(:read, hidden_test) }
      it{ should_not be_able_to(:create, hidden_test) }
      it{ should_not be_able_to(:update, hidden_test) }
      it{ should_not be_able_to(:destroy, hidden_test) }
    end
  end

  describe "comment" do
    let(:comment) { Fabricate :comment }
    it{ should be_able_to(:read, comment) }
    it{ should be_able_to(:create, comment) }
    it{ should_not be_able_to(:update, comment) }
    it{ should_not be_able_to(:destroy, comment) }
  end

  describe "contest" do
    let(:contest) { Fabricate :contest }

    it{ should be_able_to(:watch, contest) }
    it{ should be_able_to(:unwatch, contest) }
    it{ should be_able_to(:read, contest) }
    it{ should be_able_to(:last, contest) }
    # but
    it{ should_not be_able_to(:manage, contest) }
  end

  describe "post" do
    context 'authored by coder' do
      let(:post) { Fabricate :post, author: coder }
      it{ should be_able_to(:manage, post) }
    end
    context 'have not authored by coder' do
      let(:post) { Fabricate :post }
      it{ should_not be_able_to(:manage, post) }
      it{ should be_able_to(:read, post) }
    end
    context 'is not blog' do
      let(:post) { Fabricate :post, category: 'help' }
      it{ should_not be_able_to(:manage, post) }
      it{ should be_able_to(:read, post) }
    end
  end

  describe "solution" do
    before do
      Solution.any_instance.stub(:save_attached_files) {true}
    end

    context "contest is not started" do
      let(:solution) do
        Fabricate.build :solution, contest: Fabricate.build(:upcoming_contest)
      end
      it{ should_not be_able_to(:create, solution) }
    end

    context "contest is ongoing" do
      let(:solution) do
        Fabricate.build :solution, contest: Fabricate.build(:ongoing_contest)
      end
      it{ should be_able_to(:create, solution) }
    end

    context "contest is finished" do
      let(:solution) do
        Fabricate.build :solution, contest: Fabricate.build(:finished_contest)
      end
      it{ should_not be_able_to(:create, solution) }
    end

    context "contest is not selected" do
      let(:solution) do
        Fabricate.build :solution, contest: nil
      end
      it{ should be_able_to(:create, solution) }
    end

    context "owned by coder" do
      let(:solution) do
        Fabricate.build :solution, user: coder
      end
      it{ should be_able_to(:read, solution) }

      context "is updated" do
        before { solution.stub(:updated?){true} }
        it{ should be_able_to(:check, solution) }
      end
      context "is not updated" do
        before { solution.stub(:updated?){false} }
        it{ should_not be_able_to(:check, solution) }
      end
      context "is not open" do
        before { solution.stub(:open?){false} }
        it{ should_not be_able_to(:update, solution) }
        it{ should_not be_able_to(:destroy, solution) }
      end
      context "is open" do
        before { solution.stub(:open?){true} }
        it{ should be_able_to(:update, solution) }
        it{ should be_able_to(:destroy, solution) }
      end

    end

    context "not owned by coder" do

      context "in competition" do
        let(:solution) do
          Fabricate.build :solution, contest: Fabricate.build(:ongoing_contest)
        end

        it{ should_not be_able_to(:read, solution) }
        it{ should_not be_able_to(:check, solution) }
        it{ should_not be_able_to(:update, solution) }
        it{ should_not be_able_to(:destroy, solution) }
      end

      context "not in competition" do
        let(:solution) do
          Fabricate.build :solution, contest: Fabricate.build(:finished_contest)
        end

        context "already solved by coder" do
          before do
            coder.stub(:solved?, solution.problem) {true}
          end
          it{ should be_able_to(:read, solution) }
          it{ should_not be_able_to(:check, solution) }
          it{ should_not be_able_to(:update, solution) }
          it{ should_not be_able_to(:destroy, solution) }
        end
        context "not yet solved by coder" do
          before do
            coder.stub(:solved?, solution.problem) {false}
          end
          it{ should_not be_able_to(:read, solution) }
          it{ should_not be_able_to(:check, solution) }
          it{ should_not be_able_to(:update, solution) }
          it{ should_not be_able_to(:destroy, solution) }
        end
      end

    end
  end
end
