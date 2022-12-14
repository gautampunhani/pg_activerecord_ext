# frozen_string_literal: true

require "active_support/logger"
require "models/college"
require "models/course"
require "models/professor"
require "models/other_dog"
require_relative  "../../lib/pg_activerecord_ext"

module ARTest
  def self.connection_name
    ENV["ARCONN"] || "postgres_pipeline"
  end

  def self.test_configuration_hashes
    config.fetch("connections").fetch(connection_name) do
      puts "Connection #{connection_name.inspect} not found. Available connections: #{config['connections'].keys.join(', ')}"
      exit 1
    end
  end

  def self.connect
    ActiveRecord::Base.legacy_connection_handling = false
    puts "Using #{connection_name}"
    ActiveRecord::Base.logger = ActiveSupport::Logger.new("debug.log", 0, 100 * 1024 * 1024)
    ActiveRecord::Base.configurations = test_configuration_hashes
    ActiveRecord::Base.establish_connection :arunit
    ARUnit2Model.establish_connection :arunit2
  end
end
