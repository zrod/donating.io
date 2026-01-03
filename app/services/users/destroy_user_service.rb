module Users
  class DestroyUserService
    attr_reader :user, :keep_contributions

    def initialize(user:, keep_contributions:)
      @user = user
      @keep_contributions = keep_contributions
    end

    def call
      User.transaction do
        if keep_contributions && user.places.any?
          user.places.update_all(user_id: User.community_user.id)
        end

        user.destroy!
      end
    end
  end
end
