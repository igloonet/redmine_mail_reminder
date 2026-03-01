namespace :redmine do
  namespace :mail_reminder do
    desc <<-END_DESC
Send all scheduled mail reminders.

This task should be run via cron (e.g. every hour or daily).
It checks all configured mail reminders and sends those whose schedule is due.

Example:
  rake redmine:mail_reminder:send RAILS_ENV="production"
END_DESC

    task send: :environment do
      reminders = MailReminder.includes(:roles, :query, :project).all
      sent_count = 0

      reminders.each do |reminder|
        next unless reminder.project
        next unless reminder.project.enabled_module_names.include?('issue_reminder')
        next unless reminder.query.present?
        next unless reminder.execute?

        # Find all users with any of the reminder's roles in this project
        users = []
        reminder.roles.each do |role|
          members = Member.joins(:member_roles)
                         .where(project_id: reminder.project_id, member_roles: { role_id: role.id })
          members.each do |member|
            user = member.principal
            users << user if user.is_a?(User) && user.active? && user.mail.present?
          end
        end

        users.uniq!

        # Send reminder to each user
        users.each do |user|
          begin
            mail = MailReminderMailer.issues_reminder(user, [[reminder.project, reminder.query]])
            mail.deliver_now if mail
            sent_count += 1
          rescue => e
            Rails.logger.error "Mail reminder error for user #{user.login}: #{e.message}"
          end
        end

        # Update executed_at timestamp
        reminder.update_column(:executed_at, Time.now)
      end

      puts "Mail reminders sent: #{sent_count} emails"
    end
  end
end
