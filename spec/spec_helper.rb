# Extend loadpath for simpler require statements
$: << Dir.pwd + '/lib/'


RSpec.configure do |config|
  # Configure the Rspec to only accept the new syntax on new projects, to avoid
  # having the 2 syntax all over the place.
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
