require 'spec_helper'

RSpec.describe ApplicationHelper do
  describe "#link_to_if_external_uri(text)" do
    let(:show_only_host) { false }
    subject { link_to_if_external_uri(text, show_only_host: show_only_host) }

    context 'when text is a uri' do
      let(:host) { 'example.com' }
      let(:text) { "https://#{host}/foo" }

      it 'returns a link to open the uri in a new window' do
        expect(subject)
          .to eq("<a target=\"_blank\" href=\"#{text}\">#{text}</a>")
      end

      context "when body option is set to true" do
        let(:show_only_host) { true }

        it "display only the uri's host in the body" do
          expect(subject)
            .to eq("<a target=\"_blank\" href=\"#{text}\">#{host}</a>")
        end
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
