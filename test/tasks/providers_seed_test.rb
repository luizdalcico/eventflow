require "test_helper"
require "rake"

class ProvidersSeedTest < ActiveSupport::TestCase
  # Load the application's rake tasks once for the whole suite.
  Rails.application.load_tasks unless Rake::Task.task_defined?("providers:seed")

  def run_seed
    task = Rake::Task["providers:seed"]
    task.reenable
    capture_io { task.invoke }
  end

  test "creates the curated suppliers" do
    assert_equal 0, Provider.count

    run_seed

    assert_operator Provider.count, :>, 0
    # All seeded records must be valid against the model rules.
    Provider.find_each { |p| assert p.valid?, "#{p.name} should be valid" }
  end

  test "every seeded provider has an allowed type" do
    run_seed

    Provider.find_each do |provider|
      assert_includes Provider::PROVIDER_TYPES, provider.provider_type
    end
  end

  test "is idempotent across re-runs" do
    run_seed
    count_after_first = Provider.count

    run_seed

    assert_equal count_after_first, Provider.count
  end

  test "keeps real phone numbers and seeds blank documents" do
    run_seed

    dayvid = Provider.find_by!(name: "Dayvid Decorações")
    assert_equal "987490597", dayvid.phone_number
    assert_equal "decoration", dayvid.provider_type
    assert_equal "", dayvid.document
  end
end
