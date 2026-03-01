class RenameIssueRemindersToMailReminders < ActiveRecord::Migration[6.1]
  def self.up
    rename_table :issue_reminders, :mail_reminders if table_exists?(:issue_reminders) && !table_exists?(:mail_reminders)
  end

  def self.down
    rename_table :mail_reminders, :issue_reminders if table_exists?(:mail_reminders) && !table_exists?(:issue_reminders)
  end
end
