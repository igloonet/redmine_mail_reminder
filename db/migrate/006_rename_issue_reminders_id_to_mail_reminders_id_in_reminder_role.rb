class RenameIssueRemindersIdToMailRemindersIdInReminderRole < ActiveRecord::Migration[6.1]
  def self.up
    if table_exists?(:reminder_roles) && column_exists?(:reminder_roles, :issue_reminder_id) && !column_exists?(:reminder_roles, :mail_reminder_id)
      rename_column :reminder_roles, :issue_reminder_id, :mail_reminder_id
    end
  end

  def self.down
    if table_exists?(:reminder_roles) && column_exists?(:reminder_roles, :mail_reminder_id) && !column_exists?(:reminder_roles, :issue_reminder_id)
      rename_column :reminder_roles, :mail_reminder_id, :issue_reminder_id
    end
  end
end
