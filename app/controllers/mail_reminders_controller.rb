class MailRemindersController < ApplicationController
  before_action :find_project
  before_action :authorize, only: :index

  def index
    @reminders = MailReminder.where(project_id: @project)
    # Clean up reminders with deleted queries
    orphaned = @reminders.select { |r| r.query.nil? }
    if orphaned.any?
      orphaned.each(&:destroy)
      @reminders = MailReminder.where(project_id: @project)
    end
    @reminder = MailReminder.new
  end

  def create
    reminder = MailReminder.new(reminder_params)
    reminder.interval_value = params[:interval_value].to_i
    if reminder.save
      Role.find_all_givable.each do |role|
        if params[role.name.downcase]
          ReminderRole.create!(mail_reminder: reminder, role: role)
        end
      end
      flash[:notice] = I18n.t(:reminder_created)
    else
      flash[:error] = I18n.t(:reminder_not_created)
    end
    redirect_to project_mail_reminders_path(@project)
  end

  def update
    reminder = MailReminder.find(params[:id])
    if reminder.update(reminder_params)
      reminder.update_column(:interval_value, params[:interval_value].to_i) if params[:interval_value]
      Role.find_all_givable.each do |role|
        if reminder.roles.include?(role) && params[role.name.downcase].nil?
          reminder.reminder_roles.find_by(role_id: role.id)&.destroy
        elsif params[role.name.downcase] && !reminder.roles.include?(role)
          ReminderRole.create!(mail_reminder: reminder, role: role)
        end
      end
      flash[:notice] = I18n.t(:reminder_updated)
    end
    redirect_to project_mail_reminders_path(@project)
  end

  def destroy
    reminder = MailReminder.find(params[:id])
    reminder.destroy
    flash[:notice] = I18n.t(:reminder_deleted)
    redirect_to project_mail_reminders_path(@project)
  end

  def update_interval_values
    vals = MailReminder.interval_values_for(params[:interval])
    begin
      reminder = MailReminder.find(params[:mail_reminder_id])
    rescue ActiveRecord::RecordNotFound
      reminder = MailReminder.new
    end

    render partial: 'interval_values',
           locals: { possible_values: vals, selected_value: nil, reminder: reminder }
  end

  private

  def reminder_params
    params.require(:reminder).permit(:project_id, :query_id, :interval)
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    @project = Project.find(params.dig(:reminder, :project_id)) if params[:reminder]
  end
end
