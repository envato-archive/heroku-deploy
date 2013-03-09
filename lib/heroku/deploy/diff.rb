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
      git %{show --pretty="format:" #{from}..#{to} #{folders.join " "}}
    end

    def has_asset_changes?
      folders_that_could_have_changes = %w(app/assets lib/assets vendor/assets Gemfile.lock)

      diff(folders_that_could_have_changes).match /diff/
    end

    def has_migrations?
      migrations_diff.match /ActiveRecord::Migration/
    end

    def has_unsafe_migrations?
      migrations_diff.match /change_column|change_table|drop_table|remove_column|remove_index|rename_column|execute/
    end

    private

    def migrations_diff
      diff %w(db/migrate)
    end
  end
end
