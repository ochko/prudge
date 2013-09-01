describe "BaseAbility" do
  subject(:ability) {BaseAbility.new(nil)}

  it{ should be_able_to(:read, Fabricate.build(:post)) }
  it{ should be_able_to(:read, Fabricate.build(:comment)) }
  it{ should be_able_to(:read, Fabricate.build(:contest)) }
  it{ should be_able_to(:read, Fabricate.build(:problem, contest: Fabricate.build(:ongoing_contest))) }
  it{ should_not be_able_to(:read, Fabricate.build(:problem, contest: Fabricate.build(:upcoming_contest))) }
  it{ should_not be_able_to(:update, Fabricate.build(:post)) }
  it{ should_not be_able_to(:create, Fabricate.build(:comment)) }
  it{ should_not be_able_to(:update, Fabricate.build(:contest)) }
  it{ should_not be_able_to(:update, Fabricate.build(:problem)) }
  it{ should_not be_able_to(:read, Fabricate.build(:solution)) }
  it{ should_not be_able_to(:create, Fabricate.build(:solution)) }
  it{ should_not be_able_to(:create, Fabricate.build(:post)) }
end
