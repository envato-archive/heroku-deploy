module Heroku::Deploy
  class Delta
    def self.calcuate_from(from, to)
      new(from, to)
    end

    attr_accessor :from, :to, :git

    def initialize(from, to)
      @from = from
      @to   = to
      @git  = Git.new
    end

    def diff(folders)
      git.diff :from => from, :to => to, :folder => folders.join(" ")
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
