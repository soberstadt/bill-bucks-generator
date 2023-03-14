require 'rails_helper'

RSpec.describe BuckImage, type: :model do
  subject do
    described_class.new(Buck.new)
  end

  describe '#to_blob' do
    it do
      expect { subject.to_blob }.to_not raise_error
    end
  end
end
