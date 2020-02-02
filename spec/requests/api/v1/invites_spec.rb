# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Invites', type: :request do
  let!(:invite) { invites(:invite_1) }
  let!(:id)     { invite.id }

  describe 'GET api/v1/invites' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'get invites with pagination params' do
          get(
            '/api/v1/invites',
            headers: headers,
            params: {
              page: {
                number: 1,
                size: 2
              }
            }
          )

          expect(status).to eq(200)

          expect(JSON.parse(response.body).count).to eq(2)
          expect(response.headers.dig('Pagination-Current-Page')).to eq(1)
          expect(response.headers.dig('Pagination-Per')).to eq(2)
          expect(response.headers.dig('Pagination-Total-Pages')).to eq(2)
          expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
        end

        # The purpose of this test is to insure the issue #20 in the original fetcheable_on_api gem (v 0.3.1) doesn't appear
        # See https://github.com/fabienpiette/fetcheable_on_api/issues/20 for details
        #
        it 'get invites with the right pagination headers when the last page is full' do
          get(
            '/api/v1/invites',
            headers: headers,
            params: {
              page: {
                number: 2,
                size: 1
              }
            }
          )

          expect(status).to eq(200)

          expect(JSON.parse(response.body).count).to eq(1)
          expect(response.headers.dig('Pagination-Current-Page')).to eq(2)
          expect(response.headers.dig('Pagination-Per')).to eq(1)
          expect(response.headers.dig('Pagination-Total-Pages')).to eq(3) # not 4!
          expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
        end

        it 'returns 1 as Pagination-Total-Pages when no record is found' do
          Invite.destroy_all

          get(
            '/api/v1/invites',
            headers: headers,
            params: {
              page: {
                number: 1,
                size: 3
              }
            }
          )

          expect(status).to eq(200)

          expect(JSON.parse(response.body).count).to eq(0)
          expect(response.headers.dig('Pagination-Current-Page')).to eq(1)
          expect(response.headers.dig('Pagination-Per')).to eq(3)
          expect(response.headers.dig('Pagination-Total-Pages')).to eq(1)
          expect(response.headers.dig('Pagination-Total-Count')).to eq(0)
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get invites as a requester' do
          get('/api/v1/invites', headers: headers)

          expect(status).to eq(403)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/invites/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get an invite as a requester' do
          get("/api/v1/invites/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/invites' do
    context 'when 400' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create an invite with missing params' do
          post(
            '/api/v1/invites',
            headers: headers,
            params: {
              email: nil,
              role: nil,
              first_name: nil,
              last_name: nil,
              laboratory: nil
            }
          )

          expect(status).to eq(400)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create an invite as a requester' do
          post('/api/v1/invites', headers: headers)

          expect(status).to eq(403)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create an invite with invalid params' do
          post(
            '/api/v1/invites',
            headers: headers,
            params: {
              email: 'foo',
              role: 'foo',
              first_name: 'foo',
              last_name: 'bar',
              laboratory: 'baz'
            }
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/invites/:id/retry' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t retry sending the invite email as a requester' do
          post("/api/v1/invites/#{id}/retry", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/invites/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete an invite as a requester' do
          delete("/api/v1/invites/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to delete an invite' do
          allow_any_instance_of(Invite).to receive(:destroy).and_return(false)

          delete("/api/v1/invites/#{id}", headers: headers)

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
