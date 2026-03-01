class MailReminder < ApplicationRecord
  has_many :reminder_roles, dependent: :destroy
  has_many :roles, through: :reminder_roles
  belongs_to :query
  belongs_to :project

  validates :query_id, presence: true

  DAILY_INTERVALS = %i[
    every_day
    every_second_day
    every_third_day
    every_fourth_day
    every_fifth_day
    every_sixth_day
  ].freeze

  def self.intervals
    %i[daily weekly monthly]
  end

  def self.daily_intervals
    DAILY_INTERVALS
  end

  def self.weekly_intervals
    Date::DAYNAMES
  end

  def self.monthly_intervals
    (1..31).to_a
  end

  def self.interval_values_for(interval)
    case interval.to_s.downcase
    when 'daily'
      daily_intervals.each_with_index.map { |val, idx| [interval_value_display('daily', val), idx] }
    when 'weekly'
      weekly_intervals.each_with_index.map { |val, idx| [interval_value_display('weekly', val), idx] }
    when 'monthly'
      monthly_intervals.map { |val| [interval_value_display('monthly', val), val] }
    else
      []
    end
  end

  def self.interval_value_display(interval, value)
    case interval
    when 'daily'
      value = daily_intervals[value] if value.is_a?(Integer)
      I18n.t(value)
    when 'weekly'
      value = Date::DAYNAMES[value] if value.is_a?(Integer)
      I18n.t(:every_weekly_format) % I18n.t(value.downcase.to_sym)
    when 'monthly'
      I18n.t(:every_of_month_format) % value
    else
      'Unknown'
    end
  end

  def execute?
    case interval
    when 'daily'  then execute_daily?
    when 'weekly' then execute_weekly?
    when 'monthly' then execute_monthly?
    else false
    end
  end

  def execute_daily?
    comparison_date = if executed_at.nil? || (updated_at > executed_at)
                        updated_at
                      else
                        executed_at
                      end
    diff = ((Time.now - comparison_date) / 1.day).round.to_i
    diff >= interval_value + 1
  end

  def execute_weekly?
    Time.now.wday == interval_value
  end

  def execute_monthly?
    if Time.days_in_month(Time.now.month) < interval_value
      Time.now.mday == Time.days_in_month(Time.now.month)
    else
      Time.now.mday == interval_value
    end
  end
end
