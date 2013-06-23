class Participant < ActiveRecord::Base
  belongs_to :contest
  belongs_to :user

  def self.grouped(attr=:user_id)
    all.reduce({}) do |reduced, participant|
      reduced[participant[attr]] = participant
      reduced
    end
  end
end
