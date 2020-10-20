module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authorize_request, only: :create
      before_action :set_user, only: %i[show update]

      def index
        users = User.page(current_page).per_page(per_page)

        options = pagination_meta_generator(request, users.total_pages)

        json_response serializer_hash(users, :user, opt: options)
      end

      def show
        json_response serializer_hash(@user, :user)
      end

      def create
        @user = User.create!(user_params)
        json_response_create(serializer_hash(@user, :user), api_v1_user_path(@user))
      end

      def update
        @user.update!(user_params)
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params
          .require(:data)
          .require(:attributes)
          .permit(
            :name,
            :username,
            :email,
            :password,
            :password_confirmation
          )
      end
    end
  end
end
