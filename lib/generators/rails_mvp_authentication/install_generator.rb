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

      def bcrypt_is_commented_out
        gemfile = path_to("Gemfile")

        File.open(gemfile).each_line do |line|
          return true if line == '# gem "bcrypt", "~> 3.1.7"'
        end

        false
      end

      def create_user_model
        template "user.rb", "app/models/user.rb"
      end

      def create_users_table
        generate "migration", "create_users_table email:string:index confirmed_at:datetime password_digest:string unconfirmed_email:string"
      end

      def gemfile
        path_to("Gemfile")
      end

      def gemfile_exists
        File.exist?(gemfile)
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
