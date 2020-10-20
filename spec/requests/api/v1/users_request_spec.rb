require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:valid_user_attributes) do 
    { 
      data: {
        type: 'user',
        attributes: attributes_for(:user)  
      } 
    } 
  end

  describe 'GET api/v1/users' do
    context 'request with headers valids' do
      before do
        create_list(:user, 5)
        resquest_get(url: api_v1_users_path, headers: authenticate_header)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_json_schema('api/v1/users') }
    end

    context 'paginate' do
      context 'when page and per_page parameters are not entered, number of records:' do
        before do
          create_list(:user, 50)
          resquest_get(url: api_v1_users_path, headers: authenticate_header)
        end

        it { expect(parse_json(response)['data'].count).to eq 10 }
      end
      
      context 'when per_page = 10 paramter is entered, number of records:' do
        before do
          create_list(:user, 50)
          resquest_get(url: api_v1_users_path(per_page: 20), headers: authenticate_header)
        end

        it { expect(parse_json(response)['data'].count).to eq 20 }
      end
    end
    
    context 'request with headers invalids' do
      before do
        resquest_get(url: api_v1_users_path, headers: invalid_headers)
      end

      it { expect(response).to have_http_status(:not_acceptable) }
    end
  end

  describe 'GET api/v1/users/:id' do
    context 'found user' do
      before do
        user = create(:user)
        resquest_get(url: api_v1_user_path(user), headers: authenticate_header)
      end
      
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_json_schema('api/v1/user') }
    end
    
    context 'not found user' do
      before do
        @id = Faker::Number.digit
        resquest_get(url: api_v1_user_path(@id), headers: authenticate_header)
        @errors = parse_json(response)['errors'][0]
      end
      
      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to match_json_schema('api/v1/not_found_error') }
      
      it 'is expected message body to eq Not found' do
        expect(@errors['title']).to eq I18n.t('errors.messages.not_found') 
      end
      
      it "is expected detais body to eq Couldn't find User with 'id'" do 
        expect(@errors['details']).to eq "Couldn't find User with 'id'=#{@id}" 
      end
    end
    
    context 'request with headers invalids' do
      before do
        resquest_get(url: api_v1_user_path(1), headers: invalid_headers)
      end
      
      it { expect(response).to have_http_status(:not_acceptable) }
    end

    context 'Internal Server Error' do
      before do
        allow(User).to receive(:find).and_raise('500 error')
        resquest_get(url: api_v1_user_path(1), headers: authenticate_header)
        @errors = parse_json(response)['errors'][0]
      end
  
      it { expect(response).to have_http_status(:internal_server_error) }
      it { expect(response).to match_json_schema('api/v1/internal_server_error') }
      it 'is expected message body to eq Internal Server Error' do 
        expect(@errors['title']).to eq I18n.t('errors.messages.internal_server_error') 
      end
    end
  end
  
  describe 'POST api/v1/users' do
    context 'valid user' do
      before do
        resquest_post(url: api_v1_users_path, params: valid_user_attributes)
      end

      it { expect(response).to have_http_status(:created) }
      it { expect(response).to match_json_schema('api/v1/user') }
    end

    context 'invalid user' do
      let(:invalid_user_attributes) do
        {
          data: {
            attributes: attributes_for(
              :user, 
              email: Faker::String.random, 
              password: '123', 
              password_confirmation: '12345'
            ) 
          }
        } 
      end

      before do
        resquest_post(url: api_v1_users_path, params: invalid_user_attributes)
        @errors = parse_json(response)
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to match_json_schema('api/v1/record_errors') }
      it "is expected title body to eq 'Validations Failed'" do 
        expect(@errors['title']).to eq I18n.t('errors.messages.validations_failed') 
      end
    end

    context 'parameter_missing' do
      let(:invalid_params) { attributes_for(:user) }

      before do
        resquest_post(url: api_v1_users_path, params: invalid_params)
        @errors = parse_json(response)['errors'][0]
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to match_json_schema('api/v1/parameter_missing_error') }
      it "is expected message body to eq 'Parameter missing'" do 
        expect(@errors['title']).to eq I18n.t('errors.messages.parameter_missing') 
      end
    end

    context 'without content_type' do
      before do
        resquest_post(url: api_v1_users_path, params: attributes_for(:user), headers: headers_accept)
      end

      it { expect(response).to have_http_status(:unsupported_media_type) }
    end

    context 'without accept ' do
      before do
        resquest_post(url: api_v1_users_path, params: attributes_for(:user), headers: headers_content_type)
      end

      it { expect(response).to have_http_status(:not_acceptable) }
    end
  end

  describe 'PUT api/v1/users/:id' do
    context 'valid user' do
      before do
        @user = create(:user)
        @name = Faker::Name.name
        user_params = { 
          data: { 
            type: 'user', 
            attributes: attributes_for(:user, name: @name) 
          }
        }
        resquest_put(url: api_v1_user_path(@user), params: user_params, headers: authenticate_header)
        @user.reload
      end

      it { expect(response).to have_http_status(:no_content) }
      it { expect(response).to be_successful }
      it { expect(@user.name).to eql @name }
    end
    
    context 'invalid user' do
      let(:invalid_user_attributes) { attributes_for(:user, email: '') }

      before do
        resquest_post(url: api_v1_users_path, params: invalid_user_attributes, headers: authenticate_header)
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to match_json_schema('api/v1/record_errors') }
    end

    context 'not found user' do
      before do
        resquest_put(url: api_v1_user_path(1), params: attributes_for(:user), headers: authenticate_header)
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    context 'without content_type' do
      before do
        resquest_put(url: api_v1_user_path(1), params: attributes_for(:user), headers: headers_accept)
      end

      it { expect(response).to have_http_status(:unsupported_media_type) }
    end

    context 'without accept ' do
      before do
        resquest_put(url: api_v1_user_path(1), params: attributes_for(:user), headers: headers_content_type)
      end

      it { expect(response).to have_http_status(:not_acceptable) }
    end
  end
end
