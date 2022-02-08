require "test_helper"
require "generators/rails_mvp_authentication/install_generator"

class RailsMvpAuthentication::InstallGeneratorTest < Rails::Generators::TestCase
  tests ::RailsMvpAuthentication::Generators::InstallGenerator
  destination Rails.root

  teardown do
    remove_if_exists("db/migrate")
    remove_if_exists("app/models/user.rb")
    remove_if_exists("Gemfile")
  end

  test "creates migration for users table" do
    run_generator
    assert_migration "db/migrate/create_users_table.rb" do |migration|
      assert_match(/add_index :users_tables, :email, unique: true/, migration)
      assert_match(/t.string :email, null: false/, migration)
      assert_match(/t.string :password_digest, null: false/, migration)
    end
  end

  test "creates user model" do
    run_generator
    assert_file "app/models/user.rb"
  end

  test "does not error if there is no Gemfile" do
    assert_nothing_raised do
      run_generator
    end
  end

  test "adds bcrypt to Gemfile" do
    FileUtils.touch Rails.root.join("Gemfile")

    run_generator
    assert_file "Gemfile", /gem "bcrypt", "~> 3.1.7"/
  end

  test "uncomments bcrypt from Gemfile" do
    File.atomic_write(Rails.root.join("Gemfile")) do |file|
      file.write('# gem "bcrypt", "~> 3.1.7"')
    end

    run_generator
    assert_file "Gemfile", /gem "bcrypt", "~> 3.1.7"/
  end

  def remove_if_exists(path)
    full_path = Rails.root.join(path)
    FileUtils.rm_rf(full_path)
  end
end
