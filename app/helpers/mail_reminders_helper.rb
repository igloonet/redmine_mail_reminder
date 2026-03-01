module MailRemindersHelper
  def queries_for_options(project_id)
    IssueQuery.visible.order("#{Query.table_name}.name ASC")
      .where(project_id.nil? ? ['project_id IS NULL'] : ['project_id IS NULL OR project_id = ?', project_id])
      .collect { |q| [q.name, q.id] }
  end

  def reminders_intervals_for_options
    MailReminder.intervals.collect { |i| [I18n.t(i).capitalize, i.to_s] }
  end

  def content_for_column(column, issue)
    value = column.value(issue)

    case value
    when String
      if column.name == :subject
        link_to(issue.subject, issue_url(issue))
      else
        h(value)
      end
    when Time
      format_time(value)
    when Date
      format_date(value)
    when Integer, Float
      if column.name == :done_ratio
        progress_bar(value, width: '80px')
      elsif column.name == :id
        link_to(h(value.to_s), issue_url(issue))
      else
        h(value.to_s)
      end
    when User
      link_to("#{value.firstname} #{value.lastname}", user_url(value))
    when Project
      link_to(value.name, project_url(value))
    when Version
      h(value.name)
    when TrueClass
      I18n.t(:general_text_Yes)
    when FalseClass
      I18n.t(:general_text_No)
    when Issue
      link_to(value.subject, issue_url(value))
    else
      h(value.to_s)
    end
  end
end
