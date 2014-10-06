require "spec_helper"

describe PayrollScheduler::Calculator do
  before(:each) {
    options = {}
    output = StringIO.new
    @writer = PayrollScheduler::Presenter.new(output)
    @calculator = PayrollScheduler::Calculator.new(@writer, options)
    @calculator.rules.public_holidays = create_test_holidays
  }

  def convert_date(strings)
    days = []
    strings.each do |string|
      days << Date.parse(string)
    end
    days
  end

  describe "Calculating valid paydays when a year and day are given" do
    context "using a set of holidays for the year 2013" do
      it "uses expected paydays when the 1st of the month is selected" do
        expected_paydays = ["2013-01-02", "2013-02-01", "2013-03-01",
                            "2013-04-01", "2013-05-01", "2013-06-03",
                            "2013-07-01", "2013-08-01", "2013-09-03",
                            "2013-10-01", "2013-11-01", "2013-12-02"]
        @calculator.options = {year: "2013", day: "1"}

        @calculator.calculate_for_default

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays when the 2nd of the month is selected" do
        expected_paydays = ["2013-01-02", "2013-02-01", "2013-03-01",
                            "2013-04-02", "2013-05-02", "2013-06-03",
                            "2013-07-02", "2013-08-02", "2013-09-03",
                            "2013-10-02", "2013-11-01", "2013-12-02"]
        @calculator.options = {year: "2013", day: "2"}

        @calculator.calculate_for_default

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays when the 7th of the month is selected" do
        expected_paydays = ["2013-01-07", "2013-02-07", "2013-03-07",
                            "2013-04-05", "2013-05-07", "2013-06-07",
                            "2013-07-05", "2013-08-07", "2013-09-06",
                            "2013-10-07", "2013-11-07", "2013-12-06"]

        @calculator.options = {year: "2013", day: "7"}

        @calculator.calculate_for_default

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays when the 25th of the month is selected" do
        expected_paydays = ["2013-01-25", "2013-02-25", "2013-03-25",
                            "2013-04-25", "2013-05-24", "2013-06-25",
                            "2013-07-25", "2013-08-23", "2013-09-25",
                            "2013-10-25", "2013-11-25", "2013-12-20"]

        @calculator.options = {year: "2013", day: "25"}

        @calculator.calculate_for_default

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays when the 29th of the month is selected" do
        expected_paydays = ["2013-01-29", "2013-02-28", "2013-03-29",
                            "2013-04-29", "2013-05-29", "2013-06-28",
                            "2013-07-29", "2013-08-29", "2013-09-27",
                            "2013-10-29", "2013-11-27", "2013-12-27"]

        @calculator.options = {year: "2013", day: "29"}

        @calculator.calculate_for_default

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays when the 31st of the month is selected" do
        expected_paydays = ["2013-01-31", "2013-02-28", "2013-03-29",
                            "2013-04-30", "2013-05-31", "2013-06-28",
                            "2013-07-31", "2013-08-30", "2013-09-30",
                            "2013-10-31", "2013-11-27", "2013-12-31"]

        @calculator.options = {year: "2013", day: "31"}

        @calculator.calculate_for_default

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end
    end
  end

  describe "Calculating paydays when a pay frequency and starting date are given" do
    context "using a set of holidays for the year 2013" do
      it "uses expected paydays for the starting date of 2013/10/5 and the frequency of 1 week" do
        expected_paydays = ["2013-10-11", "2013-10-18", "2013-10-25",
                            "2013-11-01", "2013-11-08", "2013-11-15",
                            "2013-11-22", "2013-11-27", "2013-12-06",
                            "2013-12-13", "2013-12-20", "2013-12-27"]
        @calculator.options = {pay_frequency: "1 week", starting_date: "2013/10/5"}

        @calculator.calculate_for_frequency

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays for the starting date of 2013/9/25 and the frequency of 1 week" do
        expected_paydays = ["2013-10-02", "2013-10-09", "2013-10-16",
                            "2013-10-23", "2013-10-30", "2013-11-06",
                            "2013-11-13", "2013-11-20", "2013-11-27",
                            "2013-12-04", "2013-12-11", "2013-12-18", "2013-12-20"]
        @calculator.options = {pay_frequency: "1 week", starting_date: "2013/9/25"}

        @calculator.calculate_for_frequency

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays for the starting date of 2013/10/5 and the frequency of 2 weeks" do
        expected_paydays = ["2013-10-18", "2013-11-01", "2013-11-15",
                            "2013-11-27", "2013-12-13", "2013-12-27"]
        @calculator.options = {pay_frequency: "2 week", starting_date: "2013/10/5"}

        @calculator.calculate_for_frequency

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays for the starting date of 2013/1/1 and the frequency of 4 weeks" do
        expected_paydays = ["2013-01-29", "2013-02-26", "2013-3-26",
                            "2013-04-23", "2013-05-21", "2013-06-18",
                            "2013-07-16", "2013-08-13", "2013-09-10",
                            "2013-10-08", "2013-11-05", "2013-12-03", "2013-12-31"]
        @calculator.options = {pay_frequency: "4 week", starting_date: "2013/1/1"}

        @calculator.calculate_for_frequency

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "uses expected paydays for the starting date of 2013/1/1 and the frequency of 13 weeks" do
        expected_paydays = ["2013-04-02", "2013-07-02", "2013-10-01","2013-12-31"]
        @calculator.options = {pay_frequency: "13 week", starting_date: "2013/1/1"}

        @calculator.calculate_for_frequency

        expect(@calculator.paydays).to eq(convert_date(expected_paydays))
      end

      it "prints an error message when an unsupported pay frequncy is chosen" do
        @calculator.options = {pay_frequency: "5 week", starting_date: "2013/1/1"}

        expect(@writer).to receive(:puts_out).with(@calculator.frequency_error_message) {@calculator.frequency_error_message}
        @calculator.calculate_for_frequency
      end
    end
  end
end
