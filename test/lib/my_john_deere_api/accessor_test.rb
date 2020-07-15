require 'support/helper'

describe 'MyJohnDeereApi::Accessor' do
  let(:retry_values) { [13, 17, 19, 23] }
  let(:exponential_retries) { (0..max_retries-1).map{|i| 2 ** i} }
  let(:max_retries) { JD::Accessor::MAX_RETRIES }

  it 'wraps an oauth access token' do
    assert_kind_of OAuth::AccessToken, accessor.access_token
  end

  describe "honors Retry-After headers" do
    it "in GET requests" do
      retry_values.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/get_retry') do
        accessor.get('/')
      end
    end

    it "in POST requests" do
      retry_values.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/post_retry') do
        accessor.post('/organizations/000000/assets')
      end
    end

    it "in PUT requests" do
      retry_values.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/put_retry') do
        accessor.put('/assets/00000000-0000-0000-0000-000000000000')
      end
    end

    it "in DELETE requests" do
      retry_values.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/delete_retry') do
        accessor.delete('/assets/00000000-0000-0000-0000-000000000000')
      end
    end
  end

  describe 'employs exponential wait times for automatic retries' do
    it "in GET requests" do
      exponential_retries[0,8].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/get_failed') do
        accessor.get('/')
      end
    end

    it "in POST requests" do
      exponential_retries[0,8].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/post_failed') do
        accessor.post('/organizations/000000/assets')
      end
    end

    it "in PUT requests" do
      exponential_retries[0,8].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/put_failed') do
        accessor.put('/assets/00000000-0000-0000-0000-000000000000')
      end
    end

    it "in DELETE requests" do
      exponential_retries[0,8].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/delete_failed') do
        accessor.delete('/assets/00000000-0000-0000-0000-000000000000')
      end
    end
  end

  describe 'when Retry-After is shorter than exponential wait time' do
    it 'chooses longer exponential time in GET requests' do
      exponential_retries[0,4].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/get_retry_too_soon') do
        accessor.get('/')
      end
    end

    it 'chooses longer exponential time in POST requests' do
      exponential_retries[0,4].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/post_retry_too_soon') do
        accessor.post('/organizations/000000/assets')
      end
    end

    it 'chooses longer exponential time in PUT requests' do
      exponential_retries[0,4].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/put_retry_too_soon') do
        accessor.put('/assets/00000000-0000-0000-0000-000000000000')
      end
    end

    it 'chooses longer exponential time in DELETE requests' do
      exponential_retries[0,4].each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      VCR.use_cassette('accessor/delete_retry_too_soon') do
        accessor.delete('/assets/00000000-0000-0000-0000-000000000000')
      end
    end
  end

  describe 'when max retries have been reached' do
    it 'returns an error for GET requests' do
      exponential_retries.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      exception = assert_raises(JD::MaxRetriesExceededError) do
        VCR.use_cassette('accessor/get_max_failed') do
          accessor.get('/')
        end
      end

      assert_equal "Max retries (#{max_retries}) exceeded for GET request: 429 Too Many Requests", exception.message
    end

    it 'returns an error for POST requests' do
      exponential_retries.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      exception = assert_raises(JD::MaxRetriesExceededError) do
        VCR.use_cassette('accessor/post_max_failed') do
          accessor.post('/organizations/000000/assets')
        end
      end

      assert_equal "Max retries (#{max_retries}) exceeded for POST request: 429 Too Many Requests", exception.message
    end

    it 'returns an error for PUT requests' do
      exponential_retries.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      exception = assert_raises(JD::MaxRetriesExceededError) do
        VCR.use_cassette('accessor/put_max_failed') do
          accessor.put('/assets/00000000-0000-0000-0000-000000000000')
        end
      end

      assert_equal "Max retries (#{max_retries}) exceeded for PUT request: 429 Too Many Requests", exception.message
    end

    it 'returns an error for DELETE requests' do
      exponential_retries.each do |retry_seconds|
        accessor.expects(:sleep).with(retry_seconds)
      end

      exception = assert_raises(JD::MaxRetriesExceededError) do
        VCR.use_cassette('accessor/delete_max_failed') do
          accessor.delete('/assets/00000000-0000-0000-0000-000000000000')
        end
      end

      assert_equal "Max retries (#{max_retries}) exceeded for DELETE request: 429 Too Many Requests", exception.message
    end
  end
end