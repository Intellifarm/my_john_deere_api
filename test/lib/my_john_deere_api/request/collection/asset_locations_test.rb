require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::AssetLocations' do
  let(:asset_id) do
    contents = File.read('test/support/vcr/get_assets.yml')
    body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
    JSON.parse(body)['values'].first['id']
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:collection) { JD::Request::Collection::AssetLocations.new(accessor, asset: asset_id) }

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = JD::Request::Collection::AssetLocations.new(accessor, asset: '123')

      assert_kind_of Hash, collection.associations
      assert_equal '123', collection.associations[:asset]
    end
  end

  describe '#resource' do
    it 'returns /assets/{asset_id}/locations' do
      assert_equal "/assets/#{asset_id}/locations", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_asset_locations', record: :new_episodes) { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size
      assert all.size > 0

      all.each do |item|
        assert_kind_of JD::Model::AssetLocation, item
      end
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_asset_locations.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_asset_locations') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'results' do
    let(:location_timestamps) do
      contents = File.read('test/support/vcr/get_asset_locations.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)['values'].map{|v| v['timestamp']}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_asset_locations') { collection.count }
      timestamps = VCR.use_cassette('get_asset_locations', record: :new_episodes) { collection.map(&:timestamp) }

      assert_kind_of Array, timestamps
      assert_equal count, timestamps.size
      assert timestamps.size > 0

      location_timestamps.each do |expected_timestamp|
        assert_includes timestamps, expected_timestamp
      end
    end
  end
end