# frozen_string_literal: true
module ActiveRecord
  class FutureResult # :nodoc:
    attr_accessor :block, :sql, :binds

    KLASSES = [ ActiveRecord::Result, Array , Integer]

    wrapping_methods = (KLASSES.inject([]) { |result, klass| result + klass.instance_methods(false) } + [:dup] - [:==]).uniq

    wrapping_methods.each do |method|
      define_method(method) do |*args, &block|
        result if @pending
        @result.send(method, *args, &block)
      end
    end

    def initialize(connection_adapter, sql, binds)
      @connection_adapter = connection_adapter
      @result = nil
      @event_buffer = nil
      @error = nil
      @pending = true
      @block = nil
      @sql = sql
      @binds = binds
    end

    def result
      # Wait till timeout until pending is false
      return @result unless @pending

      @connection_adapter.initialize_results(self)
      @result
    end

    def assign(result)
      @result = result
      @result = @block.call(result) if @block
      @pending = false
    end

    def assign_error(error)
      @error = error
      @pending = false
    end

    def ==(other)
      if other.is_a?(ActiveRecord::FutureResult)
        super
      else
        result if @pending
        @result == other
      end
    end
  end
end
