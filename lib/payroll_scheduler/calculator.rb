require "date"
require "payroll_scheduler/rules"

module PayrollScheduler
  class Calculator

    attr_accessor :paydays, :options, :rules

    def initialize(writer, options = {})
      @writer = writer
      @options = options
      @paydays = []
      @rules = Rules.new(options[:public_holidays_path])
    end

    def create_schedule
      if @options[:pay_frequency].nil?
        calculate_for_default
      else
        calculate_for_frequency
      end
    end

    def calculate_for_default
      (1..12).each do |month|
        selected_day = @rules.get_valid_day(@options[:year].to_i, month, @options[:day].to_i)
        @paydays << @rules.calculate_payday(selected_day)
        @writer.format_puts_out(@rules.calculate_payday(selected_day))
      end
    end

    def calculate_for_frequency
      case @options[:pay_frequency]
      when "1 week"
        get_frequency_paydays(7)
      when "2 week"
        get_frequency_paydays(14)
      when "4 week"
        get_frequency_paydays(28)
      when "13 week"
        get_frequency_paydays(91)
      else
        @writer.puts_out(frequency_error_message)
      end
    end

    def get_frequency_paydays(frequency_int)
      starting_date = Date.parse(@options[:starting_date])
      selected_date = starting_date
      current_year = starting_date.year
      while @rules.get_last_day_of(current_year) >= starting_date
        selected_date = @rules.calculate_payday(starting_date += frequency_int)
        return if selected_date > @rules.get_last_day_of(current_year)
        @paydays << selected_date
        @writer.format_puts_out(@rules.calculate_payday(selected_date))
      end
    end

    def frequency_error_message
      "Please enter a valid pay frequency.\nOptions : 1 week, 2 week, 4 week, 13 week"
    end
  end
end
