module Users
  class DestroyUserJob < ApplicationJob
    def perform(user_id, keep_contributions)
      user = User.find_by(id: user_id)
      return unless user

      Users::DestroyUserService.new(user:, keep_contributions:).call
    end
  end
end
