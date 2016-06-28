require 'coverfield/config'
require 'coverfield/report'

describe Coverfield::Report do
  subject { Coverfield::Report }

  let(:config) { Coverfield::Config.new }

  describe '#should_display_line?' do
    context "while it shouldn't skip covered classes" do
      subject { Coverfield::Report.new(config, []) }

      context 'and there are no relevant methods' do
        it 'returns false' do
          expect(subject.instance_eval { should_display_line?(0, true) }).to eq(false)
          expect(subject.instance_eval { should_display_line?(0, false) }).to eq(false)
        end
      end

      context 'and there are relevant methods' do
        context 'coverage is 100%' do
          it 'returns true' do
            expect(subject.instance_eval { should_display_line?(1, true) }).to eq(true)
          end
        end

        context 'and coverage is below 100%' do
          it 'returns true' do
            expect(subject.instance_eval { should_display_line?(1, false) }).to eq(true)
          end
        end
      end
    end

    context 'while it should skip covered classes' do
      subject do
        cfg = config
        cfg.uncovered_only = true
        Coverfield::Report.new(cfg, [])
      end

      context 'and there are no relevant methods' do
        it 'returns false' do
          expect(subject.instance_eval { should_display_line?(0, true) }).to eq(false)
          expect(subject.instance_eval { should_display_line?(0, false) }).to eq(false)
        end
      end

      context 'and there are relevant methods' do
        context 'coverage is 100%' do
          it 'returns false' do
            expect(subject.instance_eval { should_display_line?(1, true) }).to eq(false)
          end
        end

        context 'and coverage is below 100%' do
          it 'returns true' do
            expect(subject.instance_eval { should_display_line?(1, false) }).to eq(true)
          end
        end
      end
    end
  end
end