require 'spec_helper'
describe User do
  describe :new do
    subject { User.new(user_id: 'some-id', company_id: 'some-other-id') }

    its(:user_id)    { should eq 'some-id' }
    its(:company_id) { should eq 'some-other-id' }
  end
end
