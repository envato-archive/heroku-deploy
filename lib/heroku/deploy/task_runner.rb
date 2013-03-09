module Heroku::Deploy
  class TaskRunner
    include Heroku::Deploy::Shell

    attr_accessor :tasks

    def initialize(tasks)
      @tasks = tasks
    end

    def perform_method_in_reverse(method)
      perform tasks.reverse, method
    end

    def perform_method(method)
      perform tasks, method
    end

    private

    def perform(tasks, method)
      performed_tasks = []
      current_task = nil

      begin
        tasks.each do |task|
          current_task = task

          performed_tasks << current_task
          current_task.public_send method
        end
      rescue Exception => e
        warning "An error occured when performing #{current_task.class.name}. Rolling back"

        performed_tasks.reverse.each do |task|
          task.public_send "rollback_#{method.to_s}"
        end

        raise e
      end
    end
  end
end
