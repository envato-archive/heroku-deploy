module Heroku::Deploy
  module Strategy
    class Base
      include Heroku::Deploy::UI

      def self.perform(deployer)
        new(deployer).perform
      end

      attr_accessor :deployer

      def initialize(deployer)
        @deployer = deployer
      end

      def new_commit
        deployer.new_commit
      end

      def deployed_commit
        deployer.deployed_commit
      end

      def app
        deployer.app
      end

      def branch
        deployer.branch
      end

      def runner
        @runner ||= Heroku::Deploy::Runner.new
      end

      def perform
      end
    end
  end
end
