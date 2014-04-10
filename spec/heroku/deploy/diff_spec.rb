require 'spec_helper'

module Heroku::Deploy::Shell
  def git(*args)
    $diff_content
  end
end

describe Heroku::Deploy::Diff do
  let(:diff) { Heroku::Deploy::Diff.new(from, to) }
  let(:from) { double }
  let(:to)   { double }

  describe '#has_unsafe_migrations?' do
    context 'when there are only safe migrations' do
      before { $diff_content = 'add_table add_column' }

      it 'returns false' do
        expect(diff).to_not have_unsafe_migrations
      end
    end

    context 'when there are unsafe migrations' do
      before { $diff_content = 'remove_column' }

      it 'returns true' do
        expect(diff).to have_unsafe_migrations
      end
    end

    context 'when there are unsafe migrations that are explicidly marked as safe' do

      it 'returns false' do
        $diff_content = 'remove_column #safe'
        expect(diff).to_not have_unsafe_migrations

        $diff_content = 'remove_column # safe'
        expect(diff).to_not have_unsafe_migrations
      end
    end

    context 'when only some of the unsafe migrations are marked' do
      before { $diff_content = "remove_column :foo #safe\nremove_column :blah" }

      it 'returns true' do
        expect(diff).to have_unsafe_migrations
      end
    end
  end
end
