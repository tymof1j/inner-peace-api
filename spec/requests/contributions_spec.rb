# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions' do
  let(:goal) { create :goal }
  let(:goal_id) { goal.id }
  let(:contribution) { create(:contribution, goal_id: goal_id) }
  let(:base_route) { "/api/goals/#{goal_id}/contributions" }

  describe 'GET /index' do
    let!(:contributions) { create_list(:contribution, 10, goal_id: goal_id) }

    it 'returns all goals' do
      get base_route
      expect(response).to be_successful
      expect(response_body.size).to eq(10)
    end
  end

  describe 'POST /create' do
    let(:invalid_params) { { contribution: { amount: '', description: '' } } }
    let(:valid_params) do
      { contribution: { amount: contribution.amount,
                        description: contribution.description, goal_id: goal_id } }
    end

    context 'with valid params' do
      it 'returns the description' do
        post base_route, params: valid_params, as: :json
        expect(response_body[:attributes][:description]).to eq(contribution.description)
      end

      it 'returns the amount' do
        post base_route, params: valid_params, as: :json
        expect(response_body[:attributes][:amount]).to eq(contribution.amount)
      end

      it 'returns a created status' do
        post base_route, params: valid_params, as: :json
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns a unprocessable entity status' do
        post base_route, params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get "#{base_route}/#{contribution.id}"
      expect(response).to be_successful
    end

    it 'should return a response in proper format' do
      get "#{base_route}/#{contribution.id}"
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

  describe 'PUT /update' do
    let(:invalid_params) { { contribution: { amount: '', description: '', goal_id: goal_id } } }
    let(:valid_params) do
      { contribution: { amount: contribution.amount,
                        description: contribution.description, goal_id: goal_id } }
    end

    context 'with valid params' do
      it 'returns the description' do
        put "#{base_route}/#{contribution.id}", params: valid_params, as: :json
        expect(response_body[:attributes][:description]).to eq(contribution.description)
      end

      it 'returns the amount' do
        put "#{base_route}/#{contribution.id}", params: valid_params, as: :json
        expect(response_body[:attributes][:amount]).to eq(contribution.amount)
      end

      it 'returns a created status' do
        put "#{base_route}/#{contribution.id}", params: valid_params, as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      it 'returns a unprocessable entity status' do
        put "#{base_route}/#{contribution.id}", params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    before do
      delete "#{base_route}/#{contribution.id}"
    end

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
