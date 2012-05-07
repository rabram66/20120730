# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'
require 'rake'

NearbyThis::Application.load_tasks

# Enable 'rake delay:<task>' to run any task as delayed job
require 'tasks/delayed_tasks' 