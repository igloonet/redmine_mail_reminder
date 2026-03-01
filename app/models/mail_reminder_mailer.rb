class MailReminderMailer < ActionMailer::Base
  helper :application
  helper :issues
  helper :mail_reminders
  include Redmine::I18n

  def self.default_url_options
    h = Setting.host_name.to_s.gsub(%r{/.*$}, '')
    { host: h, protocol: Setting.protocol }
  end

  def issues_reminder(user, queries_data)
    User.current = user
    @queries_data = []
    queries_data.each do |project, query|
      query.project = project
      issues = query.issues
      @queries_data << [project, query, issues] if issues.any?
    end

    # Skip sending if no issues match any query
    return if @queries_data.empty?

    headers['X-Mailer'] = 'Redmine'
    headers['X-Redmine-Host'] = Setting.host_name
    headers['X-Redmine-Site'] = Setting.app_title
    headers['X-Auto-Response-Suppress'] = 'OOF'
    headers['Auto-Submitted'] = 'auto-generated'
    headers['From'] = Setting.mail_from
    headers['List-Id'] = "<#{Setting.mail_from.to_s.gsub('@', '.')}>"

    set_language_if_valid(user.language)
    mail(
      to: user.mail,
      from: Setting.mail_from,
      subject: Setting.plugin_redmine_mail_reminder['issue_reminder_mail_subject'].presence || 'Issue Reminder'
    )
  end
end
