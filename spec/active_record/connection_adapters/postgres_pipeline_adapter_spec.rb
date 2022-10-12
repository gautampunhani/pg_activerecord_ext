# frozen_string_literal: true
require 'spec_helper'
require 'active_record'
require 'active_record/connection_adapters/postgres_pipeline_adapter'

RSpec.describe 'ActiveRecord::ConnectionAdapters::PostgresPipelineAdapter' do
  before(:all) do
    @pipeline_connection = ActiveRecord::Base.pipeline_postgresql_connection(min_messages: 'warning')
    @connection = ActiveRecord::Base.postgresql_connection(min_messages: 'warning')
    @connection.exec_query('CREATE TABLE IF NOT EXISTS postgresql_pipeline_test_table (
      id SERIAL PRIMARY KEY,
      number integer
      );')

    @connection.exec_insert('insert into postgresql_pipeline_test_table (number) VALUES (1)', nil, [], 'id', 'postgresql_pipeline_test_table_id_seq')
    @connection.exec_insert('insert into postgresql_pipeline_test_table (number) VALUES (1)', nil, [], 'id', 'postgresql_pipeline_test_table_id_seq')
  end

  it 'pipeline mode should be on in connection' do
    raw_conn = @pipeline_connection.instance_variable_get(:@connection)
    expect(raw_conn.pipeline_status).to eq PG::PQ_PIPELINE_ON
  end

  it 'should send the query in pipeline mode' do
    @pipeline_connection.exec_query('SELECT 1')
    @pipeline_connection.exec_query('SELECT 1')

    piped_results = @pipeline_connection.instance_variable_get(:@piped_results)
    expect(piped_results.try(:length)).to eq 2
  end

  describe 'Using exec_query' do
    it 'should return same results for normal and pipeline mode' do
      result = @connection.exec_query('select max(id) from postgresql_pipeline_test_table')
      expect = @pipeline_connection.exec_query('select max(id) from postgresql_pipeline_test_table')

      # Assertions
      expect(expect.result.rows.first.first).to eq result.rows.first.first
    end

    it 'should be able to return multiple query results in pipeline' do
      result_1 = @connection.exec_query('select max(id) from postgresql_pipeline_test_table')
      result_2 = @connection.exec_query('select min(id) from postgresql_pipeline_test_table')
    
      expect_1 = @pipeline_connection.exec_query('select max(id) from postgresql_pipeline_test_table')
      expect_2 = @pipeline_connection.exec_query('select min(id) from postgresql_pipeline_test_table')

      expect(expect_2.result.rows.first.first).to eq result_2.rows.first.first
      expect(expect_1.result.rows.first.first).to eq result_1.rows.first.first
    end

    it 'should be loaded correctly from ActiveRecord' do
      # Given
      connection = ActiveRecord::Base.postgresql_connection(min_messages: 'warning')

      result = connection.exec_insert('insert into postgresql_pipeline_test_table (number) VALUES (1)', nil, [], 'id', 'postgresql_pipeline_test_table_id_seq')

      # Dummy User which is configured to use pipeline connection
      # Invocation
      # user = User.load()
      # Assertions
      # expect(user).to eq result.rows.first.first

      assert_equal 1, 2
    end

    it 'should load entities in same order as called' do
      assert_equal 1, 2
    end

    it 'should insert entity in pipeline mode' do
      assert_equal 1, 2
    end

    it 'should return error if one of the query is incorrect' do
      assert_equal 1, 2
    end
  end

  describe 'Using query' do
    it 'should assign the results back in the same order, as it was called' do
      assert_equal 1, 2
    end
  end
end