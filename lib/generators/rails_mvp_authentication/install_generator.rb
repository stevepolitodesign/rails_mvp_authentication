module RailsMvpAuthentication
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Rails authentication via a generator."

      def perform
        create_users_table
        modify_users_table
        create_user_model
        add_bcrypt
        add_routes
        create_current_model
        create_users_controller
        create_user_views
        create_confirmations_controller
        create_confirmation_views
        ceate_user_mailer
        ceate_user_mailer_views
        configure_hosts
        create_authentication_concern
        modify_application_controller
        create_sessions_controller
        create_session_views
        create_passwords_controller
        create_password_views
        print_instructions
      end

      private

      def add_bcrypt
        return unless gemfile_exists

        if bcrypt_is_commented_out
          uncomment_lines(gemfile, /gem "bcrypt", "~> 3.1.7"/)
        else
          gem "bcrypt", "~> 3.1.7"
        end
      end

      def add_routes
        route %(
          post "sign_up", to: "users#create"
          get "sign_up", to: "users#new"
          put "account", to: "users#update"
          get "account", to: "users#edit"
          delete "account", to: "users#destroy"
          resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token
          post "login", to: "sessions#create"
          delete "logout", to: "sessions#destroy"
          get "login", to: "sessions#new"
          resources :passwords, only: [:create, :edit, :new, :update], param: :password_reset_token
          resources :active_sessions, only: [:destroy] do
            collection do
              delete "destroy_all"
            end
          end
        )
      end

      def bcrypt_is_commented_out
        gemfile = path_to("Gemfile")

        File.open(gemfile).each_line do |line|
          return true if line == '# gem "bcrypt", "~> 3.1.7"'
        end

        false
      end

      def configure_hosts
        application(nil, env: "test") do
          'config.action_mailer.default_url_options = {host: "example.com"}'
        end
        application(nil, env: "development") do
          'config.action_mailer.default_url_options = {host: "localhost", port: 3000}'
        end
      end

      def create_authentication_concern
        template "authentication.rb", "app/controllers/concerns/authentication.rb"
      end

      def create_confirmations_controller
        template "confirmations_controller.rb", "app/controllers/confirmations_controller.rb"
      end

      def create_confirmation_views
        template "views/confirmations/new.html.erb", "app/views/confirmations/new.html.erb"
      end

      def create_current_model
        template "current.rb", "app/models/current.rb"
      end

      def create_passwords_controller
        template "passwords_controller.rb", "app/controllers/passwords_controller.rb"
      end

      def create_password_views
        template "views/passwords/new.html.erb", "app/views/passwords/new.html.erb"
        template "views/passwords/edit.html.erb", "app/views/passwords/edit.html.erb"
      end

      def create_sessions_controller
        template "sessions_controller.rb", "app/controllers/sessions_controller.rb"
      end

      def create_session_views
        template "views/sessions/new.html.erb", "app/views/sessions/new.html.erb"
      end

      def create_users_controller
        template "users_controller.rb", "app/controllers/users_controller.rb"
      end

      def ceate_user_mailer
        template "user_mailer.rb", "app/mailers/user_mailer.rb"
      end

      def ceate_user_mailer_views
        template "views/user_mailer/confirmation.html.erb", "app/views/user_mailer/confirmation.html.erb"
        template "views/user_mailer/confirmation.text.erb", "app/views/user_mailer/confirmation.text.erb"
        template "views/user_mailer/password_reset.html.erb", "app/views/user_mailer/password_reset.html.erb"
        template "views/user_mailer/password_reset.text.erb", "app/views/user_mailer/password_reset.text.erb"
      end

      def create_user_model
        template "user.rb", "app/models/user.rb"
      end

      def create_users_table
        generate "migration", "create_users_table email:string:index confirmed_at:datetime password_digest:string unconfirmed_email:string"
      end

      def create_user_views
        template "views/users/edit.html.erb", "app/views/users/edit.html.erb"
        template "views/users/new.html.erb", "app/views/users/new.html.erb"
      end

      def gemfile
        path_to("Gemfile")
      end

      def gemfile_exists
        File.exist?(gemfile)
      end

      def modify_application_controller
        inject_into_file "app/controllers/application_controller.rb", "\tinclude Authentication\n", after: "class ApplicationController < ActionController::Base\n"
      end

      def modify_users_table
        migration = Dir.glob(Rails.root.join("db/migrate/*")).max_by { |f| File.mtime(f) }
        gsub_file migration, /t.string :email/, "t.string :email, null: false"
        gsub_file migration, /t.string :password_digest/, "t.string :password_digest, null: false"
        gsub_file migration, /add_index :users_tables, :email/, "add_index :users_tables, :email, unique: true"
      end

      def path_to(path)
        Rails.root.join(path)
      end

      def print_instructions
        readme "README"
      end
    end
  end
end
