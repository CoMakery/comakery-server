require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'contribution_licenses' do
    it 'renders the latest version of license' do
      get :contribution_licenses, params: { type: 'CP' }
      expect(response).to render_template('pages/contribution_licenses')
      expect(assigns[:license_md]).to include('CP-1.0.0')
    end

    it 'renders specific version (hash) of license if provided with one' do
      get :contribution_licenses, params: { type: 'CP', hash: '7816ea47416db43a1e517d7229208bf43a09fee4215a0b02f7db705e7e7ec59a' }
      expect(response).to render_template('pages/contribution_licenses')
      expect(assigns[:license_md]).to include('CP-1.0.0')
    end

    it 'redirects to 404 if license with given type is not found' do
      get :contribution_licenses, params: { type: 'dummy' }
      expect(response).to redirect_to('/404.html')
    end

    it 'redirects to 404 if license with given version (hash) is not found' do
      get :contribution_licenses, params: { type: 'CP', hash: 'dummy' }
      expect(response).to redirect_to('/404.html')
    end
  end

  it 'access joinus' do
    get :join_us
    expect(response).to render_template('pages/join_us')
  end

  it 'access e-sign disclosure' do
    get :e_sign_disclosure
    expect(response).to render_template('pages/e_sign_disclosure')
  end

  it 'access privacy policy' do
    get :privacy_policy
    expect(response).to render_template('pages/privacy_policy')
  end

  it 'access prohibited use policy' do
    get :prohibited_use
    expect(response).to render_template('pages/prohibited_use')
  end

  it 'access user agreement' do
    # allow(ENV).to receive(:[]).with('BASIC_AUTH').and_return('test:test')
    get :user_agreement
    expect(response).to render_template('pages/user_agreement')
  end

  it 'access featured page' do
    get :featured
    expect(response.status).to eq(200)
  end

  it 'create interest' do
    account = create :account
    project = create :project
    login account
    stub_airtable
    post :add_interest, params: { project_id: project.id, protocol: 'Vevue', format: :json }
    interest = assigns['interest']
    expect(interest.project).to eq project
    expect(interest.protocol).to eq 'Vevue'
  end

  it 'basic auth' do
    ENV.stub(:key?) { 'test:test' }
    ENV.stub(:fetch) { 'test:test' }
    get :featured
  end

  it 'redirects from styleguide page' do
    get :styleguide
    expect(response.status).to eq(302)
  end

  it 'returns styleguide page in dev env' do
    env_backup = Rails.env
    Rails.env  = 'development'
    get :styleguide
    Rails.env = env_backup
    expect(response.status).to eq(200)
  end
end
