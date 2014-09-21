module Pacto
  describe Configuration do
    subject(:configuration) { described_class.new }
    let(:contracts_path) { 'path_to_contracts' }

    it 'sets the http adapter by default to WebMockAdapter' do
      expect(configuration.adapter).to be_kind_of Stubs::WebMockAdapter
    end

    it 'sets strict matchers by default to true' do
      expect(configuration.strict_matchers).to be true
    end

    it 'sets contracts path by default to .' do
      expect(configuration.contracts_path).to eq('.')
    end

    it 'sets logger by default to Logger' do
      expect(configuration.logger).to be_kind_of Logger::SimpleLogger
    end

    context 'about logging' do

      context 'when PACTO_DEBUG is enabled' do
        around do |example|
          ENV['PACTO_DEBUG'] = 'true'
          example.run
          ENV.delete 'PACTO_DEBUG'
        end

        it 'sets the log level to debug' do
          expect(configuration.logger.level).to eq :debug
        end
      end

      context 'when PACTO_DEBUG is disabled' do
        it 'sets the log level to default' do
          expect(configuration.logger.level).to eq :error
        end
      end
    end
  end
end
