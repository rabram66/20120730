require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context 'roles' do
    should 'defaults to guest' do
      user = User.new
      assert user.role?(:guest)
    end
    should 'can be set' do
      user = User.new
      user.roles = [:promoter, :admin]
      assert user.role?(:promoter)
      assert user.role?(:admin)
    end
  end
end
