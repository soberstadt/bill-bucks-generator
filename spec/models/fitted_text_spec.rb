require 'rails_helper'

RSpec.describe FittedText, type: :model do
  subject do
    described_class.new(510)
  end

  describe '#fit_text' do
    context 'with no spaces' do
      let(:text) do
        'https://bill-buck-generator.herokuapp.com/?to=Shelby+Benton&for_message=Your+hard+work&buck_type=vonette'
      end
      it 'returns original text' do
        expect(subject.fit_text(text)).to eq text
      end
    end

    context 'with non-wrapping text' do
      let(:text) { "hello\r\nmy\r\nname \r\nis\r\n\r\nshelby" }
      it 'returns original text' do
        expect(subject.fit_text(text)).to eq text
      end
    end

    context 'with wrapping text' do
      let(:text) { 'this is a really long line of text that should wrap.' }
      let(:wrapped_text) do
        "this is a really long line of text that should\nwrap."
      end
      it 'returns wrapped text' do
        expect(subject.fit_text(text)).to eq wrapped_text
      end
    end

    context 'with wrapping and new lines' do
      let(:text) do
        "this is a really long line of text that should wrap.\r\n\r\n- Bill"
      end
      let(:wrapped_text) do
        "this is a really long line of text that should\nwrap.\r\n\r\n- Bill"
      end
      it 'returns wrapped text' do
        expect(subject.fit_text(text)).to eq wrapped_text
      end
    end

    context 'with one really long word' do
      let(:text) do
        "check this out: https://bill-buck-generator.herokuapp.com/?to=Shelby+Benton&for_message=Your+hard+work&buck_type=vonette\r\n You won't believe what happens next"
      end
      let(:wrapped_text) do
        "check this out:\nhttps://bill-buck-generator.herokuapp.com/?to=Shelby+Benton&for_message=Your+hard+work&buck_type=vonette\r\n\nYou won't believe what happens next"
      end
      it 'returns original text' do
        expect(subject.fit_text(text)).to eq wrapped_text
      end
    end
  end
end
