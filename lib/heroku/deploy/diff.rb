module Heroku::Deploy
  class Diff
    include Shell

    def self.diff(*args)
      new(*args)
    end

    attr_accessor :from, :to

    def initialize(from, to)
      @from = from
      @to   = to
    end

    def diff(folders)
      git %{diff #{from}..#{to} #{folders.join " "}}
    end

    def has_asset_changes?
      folders_that_could_have_changes = %w(app/assets lib/assets vendor/assets Gemfile.lock)
      folders_that_exist = folders_that_could_have_changes.select { |folder| File.exist?(folder) }

      diff(folders_that_exist).match /diff/
    end

    def has_migrations?
      migrations_diff.match /ActiveRecord::Migration/
    end

    def has_unsafe_migrations?
      migrations_diff.split("\n").any? do |line|
        has_unsafe_keyword?(line) && has_no_safe_override?(line)
      end
    end

    private

    def has_unsafe_keyword?(line)
      line.match(unsafe_migration_regexp)
    end

    def has_no_safe_override?(line)
      !line.match(safe_override_regexp)
    end

    def unsafe_migration_regexp
      /change_column|change_table|drop_table|remove_column|remove_index|rename_column|execute|rename_table/
    end

    def safe_override_regexp
      /#\s*safe/
    end

    def migrations_diff
      diff %w(db/migrate)
    end
  end
end
