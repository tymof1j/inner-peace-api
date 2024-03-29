# frozen_string_literal: true

require 'devise/jwt/test_helpers'
require 'rails_helper'

RSpec.describe 'Contributions' do
  let(:user) { create(:user) }
  let(:goal) { create(:goal, user_id: user.id) }
  let(:goal_id) { goal.id }
  let(:contribution) { create(:contribution, goal_id: goal_id, user_id: user.id) }
  let(:base_route) { "/api/goals/#{goal_id}/contributions" }
  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /index' do
    let!(:contributions) do
      create_list(:contribution, 10, goal_id: goal_id, user_id: user.id)
    end

    it 'returns all goals' do
      get base_route, headers: auth_headers
      expect(response).to be_successful
      expect(response_body.size).to eq(10)
    end
  end

  describe 'POST /create' do
    let(:invalid_params) { { contribution: { amount: '', description: '' } } }
    let(:valid_params) do
      {
        contribution: { amount: contribution.amount,
                        description: contribution.description, goal_id: goal_id,
                        user_id: user.id }
      }
    end

    context 'with valid params' do
      it 'returns the description' do
        post base_route, headers: auth_headers, params: valid_params, as: :json
        expect(response_body[:attributes][:description]).to eq(contribution.description)
      end

      it 'returns the amount' do
        post base_route, headers: auth_headers, params: valid_params, as: :json
        expect(response_body[:attributes][:amount]).to eq(contribution.amount)
      end

      it 'returns a created status' do
        post base_route, headers: auth_headers, params: valid_params, as: :json
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns a unprocessable entity status' do
        post base_route, headers: auth_headers, params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get "#{base_route}/#{contribution.id}", headers: auth_headers
      expect(response).to be_successful
    end

    it 'should return a response in proper format' do
      get "#{base_route}/#{contribution.id}", headers: auth_headers
      expected = response_body
      aggregate_failures do
        expect(expected[:id]).to eq(contribution.id.to_s)
        expect(expected[:type]).to eq('contribution')
        expect(expected[:attributes]).to eq(
          description: contribution.description,
          amount: contribution.amount
        )
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'returns status code 204' do
      delete "#{base_route}/#{contribution.id}", headers: auth_headers
      expect(response).to have_http_status(204)
    end
  end
end
