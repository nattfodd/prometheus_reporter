# frozen_string_literal: true

describe PrometheusReporter::TextFormatter do
  let(:formatter) { described_class.new }
  let(:key)       { :emails_today }
  let(:timestamp) { 1515748928 }

  before { PrometheusReporter.instance_variable_set(:@config, nil) }

  describe 'configuration' do
    context 'when prefix specified via #configure' do
      before do
        PrometheusReporter.configure do |c|
          c.prefix = 'crazy'
        end
        formatter.entry(key, value: 77)
      end

      it 'appends prefix to every key by default' do
        expect(formatter.to_s).to eq("crazy_emails_today 77\n")
      end

      context 'when prefix is overwrited on initialize' do
        let(:formatter) { described_class.new(prefix: 'milo_moire') }

        it 'appends overwritten prefix to metric keys' do
          expect(formatter.to_s).to eq("milo_moire_emails_today 77\n")
        end
      end
    end

    context 'when unknown key passed to config' do
      it 'raises UnknownConfig error' do
        expect { PrometheusReporter.configure { |c| c.foo = 'bar' } }
          .to raise_error(PrometheusReporter::UnknownConfig)
      end
    end
  end
end
