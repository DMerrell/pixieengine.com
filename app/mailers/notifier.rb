class Notifier < ActionMailer::Base
  default :from => 'Pixie <notifications@pixieengine.com>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifier.received_feedback.subject
  #
  def received_feedback(feedback)
    @feedback = feedback

    mail :to => "yahivin@gmail.com", :reply_to => feedback.email_address || (feedback.user ? feedback.user.email : nil)
  end

  def welcome_email(user)
    @user = user
    mail :subject => "Welcome to Pixie",
      :to => user.email
  end

  def invitation(invite)
    user = invite.user
    @invite = invite
    mail :subject => "You're invited to join Pixie!",
      :to => invite.email,
      :from => "#{user.display_name} <#{user.email}>"
  end

  def newsletter(user)
    @user = user
    mail :subject => "Pixie Newsletter",
      :to => user.email
  end

  def forgot_password(user)
    @user = user
    mail :to => user.email
  end

  def comment(comment)
    @comment = comment

    mail :subject => "#{comment.commentee.display_name}, #{comment.commenter.display_name} has commented on your Pixie item.",
      :to => comment.commentee.email
  end

  def analytics(user)
    @user = user

    graph_png = File.join(Rails.root, 'graph.png')
    report_html = File.join(Rails.root, 'report.html')

    attachments['graph.png'] = File.read graph_png if File.exist?(graph_png)
    attachments['report.html'] = File.read report_html if File.exist?(report_html)

    mail :subject => "Weekly Analytics", :to => user.email
  end

  def new_post(post)
    @post = post

    users = [User.find(1), User.find(4)]

    users.each do |user|
      mail :subject => "A new post has been created", :to => user.email
    end
  end
end
