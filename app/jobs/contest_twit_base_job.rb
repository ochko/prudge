class ContestTwitBaseJob
  @queue = :twit

  def post_for(subject, contest)
    I18n.t(subject,
           :scope => [:twit],
           :name  => contest.name,
           :url   => contest_url(contest),
           :start => contest.start,
           :end   => contest.end)
  end

  private

  def contest_url(contest)
    Rails.application.routes.url_helpers.contest_url(contest)
  end
end
