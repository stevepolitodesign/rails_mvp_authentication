require "test_helper"
require "generators/rails_mvp_authentication/install_generator"

class RailsMvpAuthentication::InstallGeneratorTest < Rails::Generators::TestCase
  tests ::RailsMvpAuthentication::Generators::InstallGenerator
  destination Rails.root

  setup :prepare_destination
  teardown :restore_destination

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

  test "should add routes" do
    run_generator

    assert_file "config/routes.rb" do |file|
      assert_match(/post "sign_up", to: "users#create"/, file)
      assert_match(/get "sign_up", to: "users#new"/, file)
      assert_match(/put "account", to: "users#update"/, file)
      assert_match(/get "account", to: "users#edit"/, file)
      assert_match(/delete "account", to: "users#destroy"/, file)
      assert_match(/resources :confirmations, only: \[:create, :edit, :new\], param: :confirmation_token/, file)
      assert_match(/post "login", to: "sessions#create"/, file)
      assert_match(/delete "logout", to: "sessions#destroy"/, file)
      assert_match(/get "login", to: "sessions#new"/, file)
      assert_match(/resources :passwords, only: \[:create, :edit, :new, :update\], param: :password_reset_token/, file)
      assert_match(/resources :active_sessions, only: \[:destroy\] do/, file)
      assert_match(/delete "destroy_all"/, file)
    end
  end

  test "should add current model" do
    run_generator

    assert_file "app/models/current.rb"
  end

  test "should create users controller" do
    run_generator

    assert_file "app/controllers/users_controller.rb"
  end

  test "should create user views" do
    run_generator

    assert_file "app/views/users/edit.html.erb"
    assert_file "app/views/users/new.html.erb"
  end

  test "should create confirmations controller" do
    run_generator

    assert_file "app/controllers/confirmations_controller.rb"
  end

  test "should create confirmation views" do
    run_generator

    assert_file "app/views/confirmations/new.html.erb"
  end

  test "should create user mailer" do
    run_generator

    assert_file "app/mailers/user_mailer.rb"
  end

  test "should create user mailer views" do
    run_generator

    assert_file "app/views/user_mailer/confirmation.html.erb"
    assert_file "app/views/user_mailer/confirmation.text.erb"
    assert_file "app/views/user_mailer/password_reset.html.erb"
    assert_file "app/views/user_mailer/confirmation.text.erb"
  end

  test "should configure hosts" do
    run_generator

    assert_file "config/environments/test.rb" do |file|
      assert_match(/config.action_mailer.default_url_options = {host: "example.com"}/, file)
    end
    assert_file "config/environments/development.rb" do |file|
      assert_match(/config.action_mailer.default_url_options = {host: "localhost", port: 3000}/, file)
    end
  end

  test "should create authentication concern" do
    run_generator

    assert_file "app/controllers/concerns/authentication.rb"
    assert_file "app/controllers/application_controller.rb" do |file|
      assert_match(/include Authentication/, file)
    end
  end

  private

  def backup_file(path)
    copy_file Rails.root.join(path), Rails.root.join("#{path}.bak")
  end

  def prepare_destination
    backup_file("config/routes.rb")
    backup_file("config/environments/test.rb")
    backup_file("config/environments/development.rb")
    backup_file("app/controllers/application_controller.rb")
  end

  def remove_if_exists(path)
    full_path = Rails.root.join(path)
    FileUtils.rm_rf(full_path)
  end

  def restore_destination
    remove_if_exists("db/migrate")
    remove_if_exists("app/models/current.rb")
    remove_if_exists("app/models/user.rb")
    remove_if_exists("app/controllers/confirmations_controller.rb")
    remove_if_exists("app/controllers/users_controller.rb")
    remove_if_exists("app/views/confirmations")
    remove_if_exists("app/views/users")
    remove_if_exists("app/mailers/user_mailer.rb")
    remove_if_exists("app/views/user_mailer")
    remove_if_exists("Gemfile")
    remove_if_exists("app/controllers/concerns/authentication.rb")
    restore_file("config/routes.rb")
    restore_file("config/environments/test.rb")
    restore_file("config/environments/development.rb")
    restore_file("app/controllers/application_controller.rb")
  end

  def restore_file(path)
    File.delete(Rails.root.join(path))
    copy_file Rails.root.join("#{path}.bak"), Rails.root.join(path)
    File.delete(Rails.root.join("#{path}.bak"))
  end
end
