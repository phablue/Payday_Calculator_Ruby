Gem::Specification.new do |s|
  s.author = "Hana Park"
  s.name = "payroll_scheduler"
  s.summary = "A payroll scheduler"
  s.version = "0.1.0"
  s.files = ["lib/payroll_scheduler.rb",
             "lib/payroll_scheduler/rules.rb",
             "lib/payroll_scheduler/calculator.rb",
             "lib/payroll_scheduler/presenter.rb"]
  s.bindir = "bin"
  s.require_paths = ["."]
  s.executables << "payroll_scheduler"
end
