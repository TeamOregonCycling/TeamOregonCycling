require 'rails_helper'

RSpec.describe CreateMembershipFromPayment do
  let(:service_args) {{
    user: user,
    payment: payment,
    success: success_handler
  }}

  let(:user) { create(:user) }
  let(:context_user) { user }

  let!(:membership_type) { create(:membership_type) }

  let(:payment) { OpenStruct.new(purchase_units: [purchase_unit]) }
  let(:purchase_unit) { OpenStruct.new(items: [item]) }
  let(:item) { OpenStruct.new(sku: membership_type.sku, unit_amount: amount) }
  let(:amount) { OpenStruct.new(value: '1.00') }

  callback_double(:success_handler)

  it 'creates a membership for the user' do
    expect(user.current_membership).to be_nil
    subject.call
    user.reload
    expect(user.current_membership.membership_type).to eq membership_type
    expect(user.current_membership.amount_paid.to_s).to eq amount.value
  end
end
