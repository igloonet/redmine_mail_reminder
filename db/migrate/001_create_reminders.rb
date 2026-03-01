class CreateReminders < ActiveRecord::Migration[6.1]
  def self.up
    unless table_exists?(:reminders) || table_exists?(:issue_reminders) || table_exists?(:mail_reminders)
      create_table :reminders do |t|
        t.column :project_id, :integer
        t.column :query_id, :integer
        t.column :interval, :string, limit: 30
        t.column :interval_value, :integer
        t.column :executed_at, :datetime
        t.timestamps
      end
    end
  end

  def self.down
    drop_table :reminders if table_exists?(:reminders)
  end
end
