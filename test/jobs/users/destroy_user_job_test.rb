require "test_helper"

module Users
  class DestroyUserJobTest < ActiveJob::TestCase
    def setup
      @user = users(:user_one)
    end

    test "should call service when user exists" do
      Users::DestroyUserService.any_instance.expects(:call).once

      DestroyUserJob.perform_now(@user.id, false)
    end

    test "should pass keep_contributions false to service" do
      service = mock
      service.expects(:call).once
      Users::DestroyUserService.expects(:new).with(user: @user, keep_contributions: false).returns(service)

      DestroyUserJob.perform_now(@user.id, false)
    end

    test "should pass keep_contributions true to service" do
      service = mock
      service.expects(:call).once
      Users::DestroyUserService.expects(:new).with(user: @user, keep_contributions: true).returns(service)

      DestroyUserJob.perform_now(@user.id, true)
    end

    test "should return early when user does not exist" do
      non_existent_id = 999999
      Users::DestroyUserService.expects(:new).never

      assert_nothing_raised do
        DestroyUserJob.perform_now(non_existent_id, false)
      end
    end

    test "should return early when user is nil" do
      Users::DestroyUserService.expects(:new).never

      assert_nothing_raised do
        DestroyUserJob.perform_now(nil, false)
      end
    end
  end
end
