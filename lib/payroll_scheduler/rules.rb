require "date"
require "json"

module PayrollScheduler
  class Rules

    attr_accessor :public_holidays

    def initialize(holidays_file_path)
      @public_holidays = assign_public_holidays(holidays_file_path)
    end

    def calculate_payday(selected_day)
      calculated_day = apply_holiday_rule(apply_weekend_rule(selected_day))
      apply_range_rule(selected_day, calculated_day)
    end

    def apply_holiday_rule(selected_day)
      while is_holiday? selected_day
        day_of_the_week = selected_day.wday
        if (1..4).include?(day_of_the_week)
          selected_day -= (day_of_the_week - 5) % 7
        else
          selected_day = get_nearest_valid_day(selected_day)
        end
      end
      selected_day
    end

    def apply_range_rule(selected_day, calculated_day)
      if outside_current_month?(selected_day, calculated_day)
        day_of_the_week = selected_day.wday
        if (0..4).include?(day_of_the_week)
          selected_day += 1
        else
          selected_day += 8 - day_of_the_week
        end
        return is_holiday?(selected_day) ? selected_day += 1 : selected_day
      end
      calculated_day
    end

    def get_valid_day(year, month, day)
      if is_valid_date?(year, month, day)
        Date.new(year, month, day)
      else
        Date.new(year, month, -1)
      end
    end

    def get_last_day_of(current_year)
      Date.new(current_year, -1, -1)
    end

    def assign_public_holidays(holidays_file_path)
      if holidays_file_path && (File.exist?(holidays_file_path))
        file = File.read(holidays_file_path)
        data_hash = JSON.parse(file)
        data_hash["public_holidays"].collect {|holiday| Date.parse(holiday["date"])}
      else
        []
      end
    end

    def outside_current_month?(selected_day, calculated_day)
      selected_day.month > calculated_day.month || selected_day.year > calculated_day.year
    end

    def get_nearest_valid_day(selected_day)
      while is_invalid_payday?(selected_day)
        selected_day -= 1
      end
      selected_day
    end

    def is_valid_date?(year, month, day)
      Date.valid_date?(year, month, day)
    end

    def is_weekend?(selected_day)
      selected_day.saturday? || selected_day.sunday?
    end

    def is_holiday?(selected_day)
      @public_holidays.include?(selected_day)
    end

    def is_invalid_payday?(selected_day)
      is_weekend?(selected_day) || is_holiday?(selected_day)
    end

    def apply_weekend_rule(selected_day)
      if is_weekend?(selected_day)
        return selected_day.saturday? ? selected_day -= 1 : selected_day -= 2
      end
      selected_day
    end
  end
end
