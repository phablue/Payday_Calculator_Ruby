require "spec_helper"

describe PayrollScheduler::Rules do

  before(:each) do
    @rules = PayrollScheduler::Rules.new(nil)
    @rules.public_holidays = create_test_holidays
  end

  def weekdays
    (Date.new(2014, 9, 1))..(Date.new(2014, 9, 5))
  end

  def weekend_days
    (Date.new(2014, 8, 30))..(Date.new(2014, 8, 31))
  end

  def non_holidays
    (Date.new(2013, 1, 22))..(Date.new(2013, 5, 25))
  end

  describe "Selecting valid dates as payroll days" do
    context "checking validity" do
      it "is a valid date if the specified date exists" do
        expect(@rules.is_valid_date?(2014, 8, 31)).to be(true)
      end

      it "is an invalid date if the specific date does not exist" do
        expect(@rules.is_valid_date?(2014, 2, 30)).to be(false)
      end
    end

    context "getting the last day of the month if the chosen date is invalid" do
      it "selects the last day of February if a day after the 28th is chosen" do
        correct_date = Date.new(2014, 2, 28)

        selected_day = @rules.get_valid_day(2014, 2, 30)

        expect(selected_day).to eq(correct_date)
      end

      it "selects the last day of September if a day after the 30th is chosen" do
        correct_date = Date.new(2014, 9, 30)

        selected_day = @rules.get_valid_day(2014, 9, 31)

        expect(selected_day).to eq(correct_date)
      end

      it "selects the chosen day if it a valid date within a month" do
        correct_date = Date.new(2014, 7, 30)

        selected_day = @rules.get_valid_day(2014, 7, 30)

        expect(selected_day).to eq(correct_date)
      end
    end

    context "getting the nearest valid day when the chosen day is invalid" do
      it "replaces the payroll day with the nearest Wednesday before Thanksgiving when Black Friday is selected" do
        selected_day = Date.new(2013, 11, 29) # Black Friday
        # 2013-11-28 is Thanksgiving Day, so the Wednesday before that should be chosen
        replacement_day = Date.new(2013, 11, 27) # Nearest Wednesday

        calculated_day = @rules.get_nearest_valid_day(selected_day)

        expect(calculated_day).to eq(replacement_day)
      end

      it "keeps the day the same if it is not a weekend or a holiday" do
        selected_day = Date.new(2013, 12, 30) # Monday, non-holiday

        calculated_day = @rules.get_nearest_valid_day(selected_day)

        expect(calculated_day).to eq(selected_day)
      end
    end
  end

  describe "Selecting only weekdays as payroll days" do
    context "checking if a day is on a weekend" do
      it "identifies every weekday as not being on a weekend" do
        weekdays.each do |day|
          expect(@rules.is_weekend?(day)).to be(false)
        end
      end

      it "identifies weekend days correctly as beong on a weekend" do
        weekend_days.each do |day|
          expect(@rules.is_weekend?(day)).to be(true)
        end
      end
    end

    context "replacing a selected day with a Friday if it falls on a weekend" do
      it "replaces the payroll day with Friday, 6-27-2014 when the selected payroll day is Sunday, 6-29-2014" do
        selected_day = Date.new(2014, 6, 29) # Sunday
        replacement_day = Date.new(2014, 6, 27) # Friday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(replacement_day)
        expect(calculated_day.friday?).to be(true)
      end

      it "correctly selects a Friday if it was the selected day" do
        selected_day = Date.new(2014, 8, 29) # Friday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(selected_day)
        expect(calculated_day.friday?).to be(true)
      end
    end
  end

  describe "Selecting non-weekend, non-holiday payroll days" do
    it "replaces the payroll day with the nearest valid day when a selected day is a weekend and the preceding Friday is a holiday" do
      selected_day = Date.new(2013, 10, 6) # Sunday
      # 2013-10-4 (Columbus Day & Friday)
      replacement_day = Date.new(2013, 10, 3) # Thursday

      calculated_day = @rules.calculate_payday(selected_day)

      expect(calculated_day).to eq(replacement_day)
      expect(calculated_day.thursday?).to be(true)
    end
  end

  describe "Identifying holidays and non-holidays" do
    context "checking if a day is a holiday" do
      it "identifies holidays" do
        @rules.public_holidays.each do |day|
          expect(@rules.is_holiday?(day)).to be(true)
        end
      end

      it "identifies non-holidays" do
        non_holidays.each do |day|
          expect(@rules.is_holiday?(day)).to be(false)
        end
      end
    end

    context "replacing payroll days with the previous Friday for selected days on non-Friday holidays" do

      it "does not replace non-weekend, non-holiday selected payroll days" do
        selected_day = Date.new(2013, 10, 29) # Tuesday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(selected_day)
        expect(calculated_day.tuesday?).to be(true)
      end

      it "replaces the payroll day with the previous Friday when the selected day is on a non-Friday holiday" do
        selected_day = Date.new(2013, 5, 27) # Memorial Day & Monday
        replacement_day = Date.new(2013, 5, 24) # Last Friday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(replacement_day)
        expect(calculated_day.friday?).to be(true)
      end

      it "replaces the payroll day with the previous Friday even if there is a non-weekend non-holiday before the invalid selected day" do
        selected_day = Date.new(2013, 12, 25) # Christmas & Wednesday
        replacement_day = Date.new(2013, 12, 20) # Last Friday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(replacement_day)
        expect(calculated_day.friday?).to be(true)
      end

      it "replaces the payroll day with a day within the year being processed" do
        selected_day = Date.new(2013, 1, 1) # New Year & Tuesday
        # 2012-12-28 is last year, but the payroll day must be within the current year
        replacement_day = Date.new(2013, 1, 2) # Wednesday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(replacement_day)
        expect(calculated_day.wednesday?).to be(true)
      end
    end

    context "selecting payment days before Friday holidays" do
      it "replaces the payroll day with a non-holiday Thursday before a holiday" do
        selected_day = Date.new(2013, 10, 4) # Columbus Day, Friday
        replacement_day = Date.new(2013, 10, 3) # Thursday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(replacement_day)
        expect(calculated_day.thursday?).to be(true)
      end
    end

    context "selecting payment days when holidays are on both Thursday and Friday" do
      it "replaces the payroll day with the Wednesday before Thanksgiving when the payroll day is Black Friday" do
        selected_day = Date.new(2013, 11, 29) # Black Friday
        # 2013-11-28 Thanks Giving Day
        replacement_day = Date.new(2013, 11, 27) # Nearest Wednesday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(replacement_day)
        expect(calculated_day.wednesday?).to be(true)
      end
    end
  end

  describe "Selecting payroll days within the specified month" do
    context "checking that calculated days are within the original payment day's month" do
      it "identifies calculated days that are outside of the given payroll day's month" do
        selected_day = Date.new(2014, 11, 1) # Saturday
        calculated_day = Date.new(2014, 10, 31) # Sunday

        result = @rules.outside_current_month?(selected_day, calculated_day)

        expect(result).to be(true)
      end

      it "identifies calculated days that are not outside of the given payroll day's month" do
        selected_day = Date.new(2014, 6, 29) # Sunday
        calculated_day = Date.new(2014, 6, 27) # Friday

        result = @rules.outside_current_month?(selected_day, calculated_day)

        expect(result).to be(false)
      end
    end

    context "replacing payroll days when calculated days are outside of the given payroll day's month" do
      it "replaces the payroll day with a valid day within the current month" do
        selected_day = Date.new(2014, 11, 1) # Saturday
        # 2014-10-31 is outside the selected_day's month
        replacement_day = Date.new(2014, 11, 3) # Monday

        calculated_day = @rules.calculate_payday(selected_day)

        expect(calculated_day).to eq(replacement_day)
      end
    end
  end
end
