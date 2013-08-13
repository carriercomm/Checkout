# desc "Explaining what the task does"
# task :checkout do
#   # Task goes here
# end

namespace :doc do
  desc "Generate a workflow graph for a model passed e.g. as 'MODEL=Order'."
  task :workflow => :environment do
    require 'workflow/draw'
    Workflow::Draw::workflow_diagram(ENV['MODEL'].constantize)
  end
end
