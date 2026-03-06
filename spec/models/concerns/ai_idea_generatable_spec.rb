require "rails_helper"

RSpec.describe AiIdeaGeneratable do
  describe ".ai_available?" do
    it "returns true when ANTHROPIC_API_KEY is set" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return("test-key")

      expect(Idea.ai_available?).to be true
    end

    it "returns false when ANTHROPIC_API_KEY is blank" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return(nil)

      expect(Idea.ai_available?).to be false
    end
  end

  describe ".generate_with_ai!" do
    let!(:channel) do
      create(:creator_channel, handle: "@typecraft_dev", niche_tags: %w[rails linux neovim])
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return("test-key")
    end

    it "returns 0 when AI is not available" do
      allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return(nil)

      expect(Idea.generate_with_ai!).to eq(0)
    end

    it "returns 0 when typecraft channel not found" do
      channel.destroy

      expect(Idea.generate_with_ai!).to eq(0)
    end

    it "returns 0 when no keywords or videos available" do
      expect(Idea.generate_with_ai!).to eq(0)
    end

    context "with trending data" do
      before do
        3.times do |i|
          create(:creator_video,
            creator_channel: channel,
            title: "Neovim setup #{i}",
            tags: %w[neovim linux],
            view_count: 10_000 * (i + 1))
        end
      end

      it "creates ideas from AI response" do
        ai_response = <<~JSON
          [
            {"title": "Building a Neovim Plugin in Rust", "angle": "Combine systems programming with editor customization", "score": 85},
            {"title": "Linux Home Server From Scratch", "angle": "Document the journey of building a complete homelab", "score": 78}
          ]
        JSON

        mock_client = instance_double(Anthropic::Client)
        mock_response = double(content: [double(text: ai_response)])

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive_message_chain(:messages, :create).and_return(mock_response)

        expect {
          Idea.generate_with_ai!(limit: 5)
        }.to change(Idea, :count).by(2)

        idea = Idea.find_by(title: "Building a Neovim Plugin in Rust")
        expect(idea.angle).to include("systems programming")
        expect(idea.score).to eq(85)
        expect(idea.status).to eq("backlog")
        expect(idea.creator_channel).to eq(channel)
      end

      it "skips duplicate titles" do
        create(:idea, title: "Building a Neovim Plugin in Rust")

        ai_response = <<~JSON
          [
            {"title": "Building a Neovim Plugin in Rust", "angle": "Duplicate idea", "score": 85},
            {"title": "New Unique Idea", "angle": "Fresh content", "score": 70}
          ]
        JSON

        mock_client = instance_double(Anthropic::Client)
        mock_response = double(content: [double(text: ai_response)])

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive_message_chain(:messages, :create).and_return(mock_response)

        expect {
          Idea.generate_with_ai!(limit: 5)
        }.to change(Idea, :count).by(1)
      end

      it "handles API errors gracefully" do
        mock_client = instance_double(Anthropic::Client)
        allow(Anthropic::Client).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive_message_chain(:messages, :create).and_raise(StandardError.new("API Error"))

        expect {
          Idea.generate_with_ai!(limit: 5)
        }.not_to change(Idea, :count)
      end

      it "handles malformed JSON response" do
        mock_client = instance_double(Anthropic::Client)
        mock_response = double(content: [double(text: "This is not JSON")])

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive_message_chain(:messages, :create).and_return(mock_response)

        expect {
          Idea.generate_with_ai!(limit: 5)
        }.not_to change(Idea, :count)
      end

      it "clamps scores between 1 and 100" do
        ai_response = <<~JSON
          [
            {"title": "Overhyped Idea", "angle": "Too ambitious", "score": 150},
            {"title": "Underhyped Idea", "angle": "Too modest", "score": -5}
          ]
        JSON

        mock_client = instance_double(Anthropic::Client)
        mock_response = double(content: [double(text: ai_response)])

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive_message_chain(:messages, :create).and_return(mock_response)

        Idea.generate_with_ai!(limit: 5)

        expect(Idea.find_by(title: "Overhyped Idea").score).to eq(100)
        expect(Idea.find_by(title: "Underhyped Idea").score).to eq(1)
      end

      it "extracts JSON from response with surrounding text" do
        ai_response = <<~RESPONSE
          Here are some ideas for your channel:

          [{"title": "Embedded JSON Idea", "angle": "Testing extraction", "score": 75}]

          Hope these help!
        RESPONSE

        mock_client = instance_double(Anthropic::Client)
        mock_response = double(content: [double(text: ai_response)])

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive_message_chain(:messages, :create).and_return(mock_response)

        expect {
          Idea.generate_with_ai!(limit: 5)
        }.to change(Idea, :count).by(1)
      end
    end
  end
end
