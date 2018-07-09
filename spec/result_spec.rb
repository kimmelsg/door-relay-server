require './lib/result.rb'

describe Result do
  describe '.success' do
    it 'returns success object' do
      result = Result.success(message: 'Testing Success', payload: 'Something')

      expect(result.success?).to eq(true)
      expect(result.message).to eq('Testing Success')
      expect(result.payload).to eq('Something')
    end

    it 'returns failure object' do
      result = Result.failure(message: 'Testing Success')

      expect(result.success?).to eq(false)
      expect(result.message).to eq('Testing Success')
      expect(result.payload).to eq(nil)
    end
  end
end
