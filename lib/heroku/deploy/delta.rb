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

    def diff
      @diff ||= git.diff :from => from, :to => to, :folder => "db/migrate"
    end

    def has_migrations?
      diff.match(/ActiveRecord::Migration/)
    end

    def has_unsafe_migrations?
      diff.match(/change_column|change_table|drop_table|remove_column|remove_index|rename_column|execute/)
    end
  end
end
