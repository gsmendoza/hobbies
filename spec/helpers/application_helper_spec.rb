require 'spec_helper'

RSpec.describe ApplicationHelper do
  describe "#link_to_if_external_uri(text)" do
    subject { link_to_if_external_uri(text) }

    context 'when text is a uri' do
      let(:text) { 'https://example.com/foo' }

      it 'returns a link to open the uri in a new window' do
        expect(subject)
          .to eq("<a target=\"_blank\" href=\"#{text}\">#{text}</a>")
      end
    end

    context 'when text is not a uri' do
      let(:text) { '/foo' }

      it 'returns the text' do
        expect(subject).to eq(text)
      end
    end
  end
end
