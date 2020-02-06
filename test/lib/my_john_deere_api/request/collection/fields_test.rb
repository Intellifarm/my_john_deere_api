require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::Fields' do
  let(:collection) { JD::Request::Collection::Fields.new(accessor, organization: organization_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = JD::Request::Collection::Fields.new(accessor, organization: organization_id)

      assert_kind_of Hash, collection.associations
      assert_equal organization_id, collection.associations[:organization]
    end
  end

  describe '#resource' do
    it 'returns /organizations/{org_id}/fields' do
      assert_equal "/organizations/#{organization_id}/fields", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_fields') { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size

      all.each do |item|
        assert_kind_of JD::Model::Field, item
      end
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_fields.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_fields') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'results' do
    let(:field_names) do
      contents = File.read('test/support/vcr/get_fields.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)['values'].map{|v| v['name']}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_fields') { collection.count }
      names = VCR.use_cassette('get_fields') { collection.map{|item| item.name} }

      assert_kind_of Array, names
      assert_equal count, names.size

      field_names.each do |expected_name|
        assert_includes names, expected_name
      end
    end
  end
end