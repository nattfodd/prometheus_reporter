# frozen_string_literal: true

describe PrometheusReporter::TextFormatter do
  let(:formatter) { described_class.new }
  let(:key)       { :emails_today }
  let(:timestamp) { 1515748928 }

  before do
    allow(PrometheusReporter).to receive(:config) { OpenStruct.new }
  end

  describe '#type' do
    context 'when unknown metric type provided' do
      it 'raises UnknownMetricType error' do
        expect { formatter.type(key, :foo_bar) }
          .to raise_error(PrometheusReporter::UnknownMetricType)
      end
    end

    context 'when type for metric is defined for the second time' do
      before do
        formatter.entry(key,
                        value: 10,
                        labels: { type: 'registration' },
                        timestamp: timestamp)
        formatter.type(key, :gauge)
      end

      it 'raises TypeAlreadySpecified error' do
        expect { formatter.type(key, :counter) }
          .to raise_error(PrometheusReporter::TypeAlreadySpecified)
      end
    end
  end

  describe '#help' do
    before do
      formatter.entry(key,
                      value: 10,
                      labels: { type: 'registration' },
                      timestamp: timestamp)
    end

    context 'when help for metric is defined for the second time' do
      before do
        formatter.help(key, 'Amount of emails sent today')
      end

      it 'raises HelpAlreadySpecified error' do
        expect { formatter.help(key, 'Emails for today') }
          .to raise_error(PrometheusReporter::HelpAlreadySpecified)
      end
    end
  end

  describe '#to_s' do
    describe 'when there is one metrics key'\
             'with multiple values & help & type provided' do
      before do
        formatter.entry(key,
                        value: 10,
                        labels: { type: 'registration' },
                        timestamp: timestamp)
        formatter.entry(key,
                        value: 15,
                        labels: { type: 'reset_password' },
                        timestamp: timestamp)
        formatter.type(key, :counter)
        formatter.help(key, 'Amount of emails sent today')
      end

      it 'returns valid text metrics' do
        expect(formatter.to_s).to eq(read_fixture('sample_01'))
      end

      context 'when prefix is provided on initialization' do
        let(:formatter) { described_class.new(prefix: 'foo_bar') }

        it 'returns valid text metrics' do
          expect(formatter.to_s).to eq(read_fixture('sample_02'))
        end
      end
    end

    context 'when there are help and type but there is no metric value' do
      before do
        formatter.type(key, :counter)
        formatter.help(key, 'Amount of emails sent today')
      end

      it 'raises MissingMetricValue error' do
        expect { formatter.to_s }
          .to raise_error(PrometheusReporter::MissingMetricValue)
      end
    end

    context "when metric's entry has no labels and timestamp" do
      before do
        formatter.entry(key, value: 5)
      end

      it 'returns valid text metrics' do
        expect(formatter.to_s).to eq("emails_today 5\n")
      end
    end

    context 'when there are multiple metrics' do
      let(:another_key) { :jobs_performed }

      before do
        formatter.entry(key,
                        value: 10,
                        labels: { type: 'registration' },
                        timestamp: timestamp)
        formatter.entry(another_key,
                        value: 33,
                        timestamp: timestamp)
        formatter.type(key, :counter)
        formatter.type(another_key, :summary)
        formatter.help(another_key, 'Total jobs performed so far')
      end

      it 'returns valid text metrics' do
        expect(formatter.to_s).to eq(read_fixture('sample_03'))
      end
    end
  end
end
