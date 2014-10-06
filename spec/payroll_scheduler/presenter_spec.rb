require "spec_helper"

describe PayrollScheduler::Presenter do
  it "formats dates" do
    payday = Date.new(2014,9,1)
    presenter = described_class.new(StringIO.new)

    expect(presenter.application_format(payday)).to eq("Monday, September 1, 2014")
  end
end
