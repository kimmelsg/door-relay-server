require 'json'

require './bootstrap'

describe Application do
  describe '#request' do
    it 'returns invalid request json for a invalid request' do
      app = described_class.new(CONFIG)

      result = app.request(scan: 1, command: 'fake', relay: 1)

      response_body = {
        success: false,
        message: 'Invalid Request'
      }.to_json
      expect(result).to eq(rack_response('400', [response_body]))
    end

    it 'returns a valid request json for a valid request' do
      app = described_class.new(CONFIG)

      result = app.request(scan: 1, command: 'off', relay: 1)

      response_body = {
        success: true,
        message: 'Mocked Success',
        payload: nil
      }.to_json
      expect(result).to eq(rack_response('200', [response_body]))
    end
  end

  def rack_response(status = '200', body = ['{"success":true}'])
    [status, { 'Content-Type:' => 'text/html' }, body]
  end
end
