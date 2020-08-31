shared_examples 'requires_signature' do
  describe described_class, type: :controller do
    controller(described_class) do
      def index
        head 200
      end
    end

    context 'when signature is present' do
      before do
        allow(controller).to receive(:verify_signature).and_return(true)
      end

      it 'does nothing' do
        get :index
        expect(response).to be_successful
      end
    end

    context 'when signature is not present' do
      before do
        allow(controller).to receive(:verify_signature).and_call_original
      end

      it 'returns an error' do
        get :index
        expect(response.status).to eq(401)
      end
    end
  end
end
