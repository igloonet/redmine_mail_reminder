Redmine::Plugin.register :redmine_mail_reminder do
  name 'Redmine Mail Reminder'
  author 'igloonet (fork of Hopebaytech/redmine_mail_reminder)'
  description 'Issue reminder plugin - sends periodic email reminders based on saved queries'
  version '4.0.0'
  url 'https://git.igloonet.cz/redmine/redmine_mail_reminder'

  permission :view_issue_reminder, { mail_reminders: [:index] }

  settings default: {
    'issue_reminder_mail_subject' => 'Issue Reminder',
    'issue_reminder_mail_header' => '',
    'issue_reminder_mail_footer' => ''
  }, partial: 'settings/issue_reminder_settings'

  project_module :issue_reminder do
    permission :view_issue_reminder, { mail_reminders: [:index, :create, :update, :destroy, :update_interval_values] }
  end

  menu :project_menu,
    :issue_reminder,
    { controller: 'mail_reminders', action: 'index' },
    caption: :issues_reminder,
    last: true,
    param: :project_id,
    if: proc { |project| project.enabled_module_names.include?('issue_reminder') }
end
