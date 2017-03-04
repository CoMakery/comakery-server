require "rails_helper"

describe "precise financial calculations across the integrated revenue sharing cycle" do
  let!(:owner) { create(:account) }

  let!(:owner_auth) { create(:authentication,
                             account: owner,
                             slack_team_id: "foo",
                             slack_image_32_url: "http://avatar.com/owner.jpg") }

  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1'*40}") }

  let!(:same_team_account_auth) { create(:authentication,
                                         account: same_team_account,
                                         slack_team_id: "lazercats",
                                         slack_team_name: "Lazer Cats") }
  before do
    stub_slack_user_list
    stub_slack_channel_list
  end

  shared_examples_for "check sums" do
    specify { expect(project.total_awards_outstanding + project.payments.total_awards_redeemed).to eq(project.total_awarded) }
    specify { expect(project.total_revenue * (project.royalty_percentage * 0.01)).to eq(project.total_revenue_shared) }
    specify { expect(project.total_revenue_shared_unpaid + project.payments.total_value_redeemed).to eq(project.total_revenue_shared) }
    specify { expect(project.share_of_revenue_unpaid(project.total_awards_outstanding)).to eq(project.total_revenue_shared_unpaid) }
    specify { expect(project.share_of_revenue_unpaid(1)).to eq(project.revenue_per_share) }

    specify do
      expect(owner_auth.total_awards_earned(project) +
                 same_team_account_auth.total_awards_earned(project)).to eq(project.total_awarded)
    end

    specify do
      expect(owner_auth.total_awards_paid(project) +
                 same_team_account_auth.total_awards_paid(project)).to eq(project.payments.total_awards_redeemed)
    end

    specify do
      expect(owner_auth.total_awards_remaining(project) +
                 same_team_account_auth.total_awards_remaining(project)).to eq(project.total_awards_outstanding)
    end

    specify do
      expect(owner_auth.total_revenue_paid(project) +
                 same_team_account_auth.total_revenue_paid(project)).to eq(project.payments.total_value_redeemed)
    end

    specify do
      expect(owner_auth.total_revenue_unpaid(project) +
                 same_team_account_auth.total_revenue_unpaid(project)).to eq(project.total_revenue_shared_unpaid)
    end
  end


  describe "empty" do
    let!(:project) { create(:project,
                            royalty_percentage: BigDecimal('99.999999'),
                            public: true,
                            owner_account: owner,
                            slack_team_id: "foo",
                            require_confidentiality: false) }

    it_behaves_like "check sums"
  end

  describe 'with revenues, awards, and payments and simple numbers' do
    let!(:project) { create(:project,
                            royalty_percentage: BigDecimal('100'),
                            public: true,
                            owner_account: owner,
                            slack_team_id: "foo",
                            require_confidentiality: false) }

    let!(:code_award_type) { project.award_types.create(community_awardable: false,
                                                        amount: 1,
                                                        name: 'Code Contribution') }
    let!(:same_team_award) { code_award_type.awards.create_with_quantity(50,
                                                                         issuer: owner,
                                                                         authentication: same_team_account_auth) }

    let!(:owner_award) { code_award_type.awards.create_with_quantity(50,
                                                                     issuer: owner,
                                                                     authentication: owner_auth) }

    let!(:revenues) { project.revenues.create(amount: 100,
                                              currency: 'USD',
                                              recorded_by: owner) }

    let!(:payments) { project.payments.create_with_quantity(quantity_redeemed: 25,
                                                            payee_auth: owner_auth) }
    it_behaves_like "check sums"
  end

  describe 'with revenues, awards, and payments and decimal royalties' do
    let!(:project) { create(:project,
                            royalty_percentage: BigDecimal('99.99'),
                            public: true,
                            owner_account: owner,
                            slack_team_id: "foo",
                            require_confidentiality: false) }

    let!(:code_award_type) { project.award_types.create(community_awardable: false,
                                                        amount: 1,
                                                        name: 'Code Contribution') }
    let!(:same_team_award) { code_award_type.awards.create_with_quantity(50,
                                                                         issuer: owner,
                                                                         authentication: same_team_account_auth) }

    let!(:owner_award) { code_award_type.awards.create_with_quantity(50,
                                                                     issuer: owner,
                                                                     authentication: owner_auth) }

    let!(:revenues) { project.revenues.create(amount: 100,
                                              currency: 'USD',
                                              recorded_by: owner) }

    let!(:payments) { project.payments.create_with_quantity(quantity_redeemed: 25,
                                                            payee_auth: owner_auth) }
    it_behaves_like "check sums"
  end

  it 'simple awards, revenue, and payments in USD' do
    # 1) create project
    project = create(:project,
                     royalty_percentage: 100,
                     public: true,
                     owner_account: owner,
                     slack_team_id: "foo",
                     require_confidentiality: false)

    # project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(0)
    expect(project.total_awards_outstanding).to eq(0)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(0)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(0)

    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)


    # ---
    # 2) issue awards
    # ---
    code_award_type = project.award_types.create(community_awardable: false, amount: 1, name: 'Code Contribution')
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: same_team_account_auth)
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: owner_auth)

    #project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)

    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 3) record revenue
    # ---

    project.revenues.create(amount: 100, currency: 'USD', recorded_by: owner)

    #project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(1)
    expect(project.total_revenue_shared).to eq(100)
    expect(project.total_revenue_shared_unpaid).to eq(100)
    expect(project.revenue_per_share).to eq(1)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)

    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(50)

    # ---
    # 4) pay contributors
    # ---

    project.payments.create_with_quantity(quantity_redeemed: 25, payee_auth: owner_auth)

    #project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_revenue_shared).to eq(100)
    expect(project.total_awards_outstanding).to eq(75)
    expect(project.total_revenue_shared_unpaid).to eq(75)
    expect(project.revenue_per_share).to eq(1)
    expect(project.share_of_revenue_unpaid(1)).to eq(1)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(25)
    expect(owner_auth.total_awards_remaining(project)).to eq(25)

    expect(owner_auth.total_revenue_paid(project)).to eq(25)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(25)

    expect(same_team_account_auth.total_awards_earned(project)).to eq(50)
    expect(same_team_account_auth.total_awards_paid(project)).to eq(0)
    expect(same_team_account_auth.total_awards_remaining(project)).to eq(50)

    expect(same_team_account_auth.total_revenue_paid(project)).to eq(0)
    expect(same_team_account_auth.total_revenue_unpaid(project)).to eq(50)
  end

  it 'high precision awards, revenue, and payments in USD' do
    almost_100 = BigDecimal('99.' + ('9'*19)) # this highlights precision and potential rounding errors
    ninety_nine_point_13_nines = almost_100.truncate(13)
    zero_point_15_nines = BigDecimal('0.' + ('9' * 15))
    seventy_four_point_13_nines_and_25 = BigDecimal('74.' + ('9' * 13) + '25')
    forty_nine_point_13_nines_and_a_five = BigDecimal('0.' + ('9' * 15)) * BigDecimal(50)

    # 1) create project
    project = create(:project,
                     royalty_percentage: almost_100,
                     public: true,
                     owner_account: owner,
                     slack_team_id: "foo",
                     require_confidentiality: false)

    expect(project.reload.royalty_percentage).to eq(ninety_nine_point_13_nines)

    # project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(0)
    expect(project.total_awards_outstanding).to eq(0)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(0)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(0)

    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)


    # ---
    # 2) issue awards
    # ---
    code_award_type = project.award_types.create(community_awardable: false, amount: 1, name: 'Code Contribution')
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: same_team_account_auth)
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: owner_auth)

    #project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)

    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 3) record revenue
    # ---

    project.revenues.create(amount: 100, currency: 'USD', recorded_by: owner)

    #project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(BigDecimal('0.' + ('9' * 15)))
    expect(project.total_revenue_shared).to eq(ninety_nine_point_13_nines)
    expect(project.total_revenue_shared_unpaid).to eq(ninety_nine_point_13_nines)
    expect(project.revenue_per_share).to eq(BigDecimal('0.' + ('9' * 15)))

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)


    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(forty_nine_point_13_nines_and_a_five)

    # ---
    # 4) pay contributors
    # ---

    payment = project.payments.create_with_quantity(quantity_redeemed: 25, payee_auth: owner_auth)
    expect(payment.total_value).to eq(24.99) # rounded to USD precision

    #project

    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_revenue_shared).to eq(ninety_nine_point_13_nines)
    expect(project.total_awards_outstanding).to eq(75)

    revenue_shared_minus_truncated_payment = ninety_nine_point_13_nines - 24.99
    expect(project.total_revenue_shared_unpaid).to eq(revenue_shared_minus_truncated_payment)

    new_price_per_share_after_reclaiming_truncated_values_like_richard_prior_in_superman3 =
        revenue_shared_minus_truncated_payment / BigDecimal('75')
    expect(project.revenue_per_share).to eq(new_price_per_share_after_reclaiming_truncated_values_like_richard_prior_in_superman3)
    expect(project.share_of_revenue_unpaid(1)).to eq(new_price_per_share_after_reclaiming_truncated_values_like_richard_prior_in_superman3)


    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(25)
    expect(owner_auth.total_awards_remaining(project)).to eq(25)

    expect(owner_auth.total_revenue_paid(project)).to eq(24.99)
    expect(owner_auth.total_revenue_unpaid(project)).to eq((revenue_shared_minus_truncated_payment * BigDecimal('25')) / BigDecimal('75'))

    expect(same_team_account_auth.total_awards_earned(project)).to eq(50)
    expect(same_team_account_auth.total_awards_paid(project)).to eq(0)
    expect(same_team_account_auth.total_awards_remaining(project)).to eq(50)

    expect(same_team_account_auth.total_revenue_paid(project)).to eq(0)
    expect(same_team_account_auth.total_revenue_unpaid(project)).
        to eq((revenue_shared_minus_truncated_payment * BigDecimal('50')) / BigDecimal('75'))
  end
end