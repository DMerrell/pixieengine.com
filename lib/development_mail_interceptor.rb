class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "mdiebolt@gmail.com" #yahivin@gmail.com
  end
end
