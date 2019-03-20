require 'rails_helper'

describe ProjectsController do
  let!(:team) { create :team }
  let!(:authentication) { create(:authentication) }
  let!(:account) { authentication.account }

  let!(:account1) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:authentication1) { create(:authentication, account: account) }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team authentication1
    login(account)
    stub_slack_channel_list
  end

  describe '#unlisted' do
    let!(:public_unlisted_project) { create(:project, account: account, visibility: 'public_unlisted', title: 'Unlisted Project') }
    let!(:member_unlisted_project) { create(:project, account: account, visibility: 'member_unlisted', title: 'Unlisted Project') }
    let!(:normal_project) { create :project, account: account }
    let!(:account2) { create :account }
    let!(:authentication2) { create(:authentication, account: account2) }

    it 'everyone can access public unlisted project via long id' do
      get :unlisted, params: { long_id: public_unlisted_project.long_id }
      expect(response.code).to eq '200'
      expect(assigns(:project)).to eq public_unlisted_project
    end

    it 'other team member cannot access member unlisted project' do
      login account2
      get :unlisted, params: { long_id: member_unlisted_project.long_id }
      expect(response).to redirect_to(root_url)
    end

    it 'team member can access member unlisted project' do
      team.build_authentication_team authentication2
      login account2
      get :unlisted, params: { long_id: member_unlisted_project.long_id }
      expect(response.code).to eq '302'
      expect(assigns(:project)).to eq member_unlisted_project
    end

    it 'redirect_to project/id page for normal project' do
      login account
      get :unlisted, params: { long_id: normal_project.long_id }
      expect(response).to redirect_to(project_path(normal_project))
    end

    it 'cannot access unlisted project by id' do
      get :show, params: { id: public_unlisted_project.id }
      expect(response).to redirect_to('/404.html')
    end
  end

  describe '#landing' do
    let!(:public_project) { create(:project, visibility: 'public_listed', title: 'public project', account: account) }
    let!(:archived_project) { create(:project, visibility: 'archived', title: 'archived project', account: account) }
    let!(:unlisted_project) { create(:project, account: account, visibility: 'member_unlisted', title: 'unlisted project') }
    let!(:member_project) { create(:project, account: account, visibility: 'member', title: 'member project') }
    let!(:other_member_project) { create(:project, account: account1, visibility: 'member', title: 'other member project') }

    describe '#login' do
      it 'redirect to account page if account info is not enough' do
        account.update country: nil
        get :landing
        expect(response).to redirect_to(build_profile_accounts_path)
      end

      it 'returns your private projects, and public projects that *do not* belong to you' do
        expect(TopContributors).to receive(:call).exactly(3).times.and_return(double(success?: true, contributors: {}))
        other_member_project.channels.create(team: team, channel_id: 'general')

        get :landing
        expect(response.status).to eq(200)
        expect(assigns[:my_projects].map(&:title)).to match_array(['public project', 'unlisted project', 'member project'])
        expect(assigns[:archived_projects].map(&:title)).to match_array(['archived project'])
        expect(assigns[:team_projects].map(&:title)).to match_array(['other member project'])
      end
    end
  describe 'logged out'
    it 'redirect to signup page if you are not logged in' do
      logout
      get :landing
      expect(response.status).to eq(302)
      expect(response).to redirect_to(new_account_url)
    end
  end

  describe '#new' do
    context 'when not logged in' do
      it 'redirects you somewhere pretty' do
        session[:account_id] = nil

        get :new

        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_account_url)
      end
    end

    context 'when logged in with unconfirmed account' do
      let!(:account1) { create :account, email_confirm_token: '123' }

      it 'redirects to home page' do
        login account1
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when slack returns successful api calls' do
      render_views

      it 'works' do
        get :new

        expect(response.status).to eq(200)
        expect(assigns[:project]).to be_a_new_record
        expect(assigns[:project]).not_to be_public
      end
    end
  end

  describe '#create' do
    render_views

    it 'when valid, creates a project and associates it with the current account' do
      expect do
        post :create, params: {
          project: {
            title: 'Project title here',
            description: 'Project description here',
            square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            tracker: 'http://github.com/here/is/my/tracker',
            contributor_agreement_url: 'http://docusign.com/here/is/my/signature',
            video_url: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0',
            slack_channel: 'slack_channel',
            maximum_tokens: '150',
            legal_project_owner: 'legal project owner',
            payment_type: 'project_token',
            token_id: create(:token).id,
            mission_id: create(:mission).id,
            require_confidentiality: false,
            exclusive_contributions: false,
            visibility: 'member'
          }
        }
        expect(response.status).to eq(200)
      end.to change { Project.count }.by(1)

      project = Project.last
      expect(project.title).to eq('Project title here')
      expect(project.description).to eq('Project description here')
      expect(project.square_image).to be_a(Refile::File)
      expect(project.panoramic_image).to be_a(Refile::File)
      expect(project.tracker).to eq('http://github.com/here/is/my/tracker')
      expect(project.contributor_agreement_url).to eq('http://docusign.com/here/is/my/signature')
      expect(project.video_url).to eq('https://www.youtube.com/watch?v=Dn3ZMhmmzK0')
      expect(project.maximum_tokens).to eq(150)
      expect(project.account_id).to eq(account.id)
    end

    it 'when invalid, returns 422' do
      expect do
        expect do
          post :create, params: {
            project: {
              # title: "Project title here",
              description: 'Project description here',
              square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              tracker: 'http://github.com/here/is/my/tracker',
              token_id: create(:token).id,
              mission_id: create(:mission).id,
              require_confidentiality: false,
              exclusive_contributions: false,
              visibility: 'member',
              award_types_attributes: [
                { name: 'Small Award', amount: 1000, community_awardable: true },
                { name: 'Big Award', amount: 2000 },
                { name: '', amount: '' }
              ]
            }
          }
          expect(response.status).to eq(422)
        end.not_to change { Project.count }
      end.not_to change { AwardType.count }

      expect(JSON.parse(response.body)['message']).to eq("Title can't be blank, Legal project owner can't be blank, Maximum tokens must be greater than 0")
      project = assigns[:project]

      expect(project.description).to eq('Project description here')
      expect(project.square_image).to be_a(Refile::File)
      expect(project.panoramic_image).to be_a(Refile::File)
      expect(project.tracker).to eq('http://github.com/here/is/my/tracker')
      expect(project.account_id).to eq(account.id)
    end

    it 'when duplicated, redirects with error' do
      expect do
        post :create, params: {
          project: {
            title: 'Project title here',
            description: 'Project description here',
            square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            tracker: 'http://github.com/here/is/my/tracker',
            contributor_agreement_url: 'http://docusign.com/here/is/my/signature',
            video_url: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0',
            slack_channel: 'slack_channel',
            maximum_tokens: '150',
            legal_project_owner: 'legal project owner',
            payment_type: 'project_token',
            token_id: create(:token).id,
            mission_id: create(:mission).id,
            long_id: '0',
            require_confidentiality: false,
            exclusive_contributions: false,
            visibility: 'member'
          }
        }
        expect(response.status).to eq(200)
      end.to change { Project.count }.by(1)

      expect do
        post :create, params: {
          project: {
            title: 'Project title here',
            description: 'Project description here',
            square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            tracker: 'http://github.com/here/is/my/tracker',
            contributor_agreement_url: 'http://docusign.com/here/is/my/signature',
            video_url: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0',
            slack_channel: 'slack_channel',
            maximum_tokens: '150',
            legal_project_owner: 'legal project owner',
            payment_type: 'project_token',
            token_id: create(:token).id,
            mission_id: create(:mission).id,
            long_id: '0',
            require_confidentiality: false,
            exclusive_contributions: false,
            visibility: 'member'
          }
        }
        expect(response.status).to eq(422)
      end.not_to change { Project.count }

      expect(JSON.parse(response.body)['message']).to eq("Long identifier can't be blank or not unique")
    end
  end

  describe '#update_status' do
    let!(:project) { create(:project) }

    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        post :update_status, params: { project_id: project.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_account_url)
      end
    end

    context 'when logged in with admin flag' do
      it 'update valid project status' do
        login admin_account
        post :update_status, params: { project_id: project.id, status: 'active' }
        expect(response.status).to eq(200)
      end

      it 'renders error with invalid status' do
        login admin_account
        post :update_status, params: { project_id: project.id, status: 'archived' }
        expect(response.status).to eq(422)
      end
    end
  end

  context 'with a project' do
    let!(:cat_project) { create(:project, title: 'Cats', description: 'Cats with lazers', account: account) }
    let!(:dog_project) { create(:project, title: 'Dogs', description: 'Dogs with donuts', account: account) }
    let!(:yak_project) { create(:project, title: 'Yaks', description: 'Yaks with parser generaters', account: account) }
    let!(:fox_project) { create(:project, title: 'Foxes', description: 'Foxes with boxes', account: account) }

    describe '#index' do
      let!(:cat_project_award) { create(:award, account: create(:account), amount: 200, award_type: create(:award_type, project: cat_project), created_at: 2.days.ago, updated_at: 2.days.ago) }
      let!(:dog_project_award) { create(:award, account: create(:account), amount: 100, award_type: create(:award_type, project: dog_project), created_at: 1.day.ago, updated_at: 1.day.ago) }
      let!(:yak_project_award) { create(:award, account: create(:account), amount: 300, award_type: create(:award_type, project: yak_project), created_at: 3.days.ago, updated_at: 3.days.ago) }

      before do
        expect(TopContributors).to receive(:call).and_return(double(success?: true, contributors: { cat_project => [], dog_project => [], yak_project => [] }))
      end

      include ActionView::Helpers::DateHelper
      it 'lists the projects ordered by most recently modify date' do
        get :index

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(%w[Yaks Dogs Cats Foxes])
        expect(assigns[:project_contributors].keys).to eq([cat_project, dog_project, yak_project])
      end

      it 'allows querying based on the title of the project, ignoring case' do
        get :index, params: { query: 'cats' }

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(['Cats'])
      end

      it 'allows querying based on the title or description of the project, ignoring case' do
        get :index, params: { query: 'o' }

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(%w[Dogs Foxes])
      end

      it 'only show public projects for not login user' do
        logout
        fox_project.public_listed!
        get :index
        expect(assigns[:projects].map(&:title)).to eq(['Foxes'])
      end

      it 'dont show archived projects for not login user' do
        logout
        cat_project.archived!
        fox_project.public_listed!
        get :index
        expect(assigns[:projects].map(&:title)).to eq(['Foxes'])
      end
    end

    describe '#edit' do
      it 'works' do
        get :edit, params: { id: cat_project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(cat_project)
      end
    end

    describe '#update' do
      it 'updates a project' do
        expect do
          put :update, params: {
            id: cat_project.to_param,
            project: {
              title: 'updated Project title here',
              description: 'updated Project description here',
              tracker: 'http://github.com/here/is/my/tracker/updated'
            }
          }
          expect(response.status).to eq(200)
        end.to change { Project.count }.by(0)

        cat_project.reload
        expect(cat_project.title).to eq('updated Project title here')
        expect(cat_project.description).to eq('updated Project description here')
        expect(cat_project.tracker).to eq('http://github.com/here/is/my/tracker/updated')
      end

      context 'with rendered views' do
        render_views
        it 'returns 422 when updating fails' do
          expect do
            put :update, params: {
              id: cat_project.to_param,
              project: {
                title: '',
                description: 'updated Project description here',
                tracker: 'http://github.com/here/is/my/tracker/updated',
                legal_project_owner: 'legal project owner',
                payment_type: 'project_token'
              }
            }
            expect(response.status).to eq(422)
          end.not_to change { Project.count }

          project = assigns[:project]
          expect(JSON.parse(response.body)['message']).to eq("Title can't be blank")
          expect(project.title).to eq('')
          expect(project.description).to eq('updated Project description here')
          expect(project.tracker).to eq('http://github.com/here/is/my/tracker/updated')
        end
      end
    end

    describe '#show' do
      let!(:awardable_auth) { create(:authentication) }

      context 'when on team' do
        it 'allows team members to view projects and assigns awardable accounts from slack api and db and de-dups' do
          login(account)
          get :show, params: { id: cat_project.to_param }

          # expect(response.code).to eq '200'
          expect(assigns(:project)).to eq cat_project
          expect(assigns[:award]).to be_new_record
          expect(assigns[:can_award]).to eq(true)
        end
      end
    end
  end
end
