class FeedbacksController < ResourceController::Base
  actions :all, :except => [:index, :show, :edit, :update, :destroy]

  before_filter :hide_feedback

  create.before do
    feedback.user = current_user
  end

  create.response do |wants|
    wants.html { redirect_to :action => :thanks }
  end

  private
  def feedback
    object
  end
end
