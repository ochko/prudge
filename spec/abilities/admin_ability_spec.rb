require 'spec_helper'

describe "AdminAbility" do
  let(:admin) { Fabricate :admin }

  subject(:ability) {AdminAbility.new(admin)}

  describe "manage" do
    it{ should be_able_to(:manage, Fabricate.build(:contest)) }
    it{ should be_able_to(:manage, Fabricate.build(:post, category: 'help')) }
    it{ should be_able_to(:manage, Fabricate.build(:solution)) }
    it{ should be_able_to(:manage, Fabricate.build(:problem)) }
    it{ should be_able_to(:manage, Fabricate.build(:comment)) }
  end

end
