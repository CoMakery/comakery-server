require 'rails_helper'

describe AwardTypeDecorator do
  describe 'display' do
    let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny' }
    let!(:project) { create :project, account: issuer }
    let!(:award_type) { create :award_type, project: project, description: 'award for contributor' }
    let!(:award) { create :award, award_type: award_type, issuer: issuer }

    it 'drescription_markdown' do
      expect(award_type.decorate.description_markdown).to eq('award for contributor')
    end
  end
end
