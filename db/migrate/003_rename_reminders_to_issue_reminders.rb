class RenameRemindersToIssueReminders < ActiveRecord::Migration[6.1]
  def self.up
    rename_table :reminders, :issue_reminders if table_exists?(:reminders) && !table_exists?(:issue_reminders)
  end

  def self.down
    rename_table :issue_reminders, :reminders if table_exists?(:issue_reminders) && !table_exists?(:reminders)
  end
end
