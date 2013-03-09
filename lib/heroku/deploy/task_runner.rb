module Heroku::Deploy
  class TaskRunner
    include Heroku::Deploy::Shell

    attr_accessor :tasks

    def initialize(tasks)
      @tasks = tasks
    end

    def perform_methods(*methods)
      performed_tasks = []
      current_task = nil

      begin
        methods.each do |method|
          tasks.each do |task|
            current_task = task
            performed_tasks << [ current_task, method ]
            current_task.public_send method
          end
        end
      rescue => e
        warning e.message
        warning "#{current_task.class.name} failed. Rolling back"

        performed_tasks.reverse.each do |task, method|
          task.public_send "rollback_#{method.to_s}"
        end

        raise e
      end
    end
  end
end
