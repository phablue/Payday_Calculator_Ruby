require "date"

module PayrollScheduler
  class Presenter
    def initialize(output = $stdout)
      @output = output
    end

    def puts_out(string)
      @output.puts(string)
    end

    def format_puts_out(payday)
      puts_out(application_format(payday))
    end

    def application_format(payday)
      payday.strftime("%A, %B %-d, %Y")
    end
  end
end
