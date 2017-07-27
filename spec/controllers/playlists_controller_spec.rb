# Copyright 2011-2017, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe PlaylistsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Playlist. As you add validations to Playlist, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, user: user }
  end

  let(:invalid_attributes) do
    { visibility: 'unknown' }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PlaylistsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { login_as :user }

  describe 'security' do
    let(:playlist) { FactoryGirl.create(:playlist) }
    context 'with unauthenticated user' do
      #New is isolated here due to issues caused by the controller instance not being regenerated
      it "should redirect to sign in" do
        expect(get :new).to redirect_to(new_user_session_path)
      end
      it "all routes should redirect to sign in" do
        expect(get :index).to redirect_to(new_user_session_path)
        expect(get :edit, id: playlist.id).to redirect_to(new_user_session_path)
        expect(post :create).to redirect_to(new_user_session_path)
        expect(put :update, id: playlist.id).to redirect_to(new_user_session_path)
        expect(put :update_multiple, id: playlist.id).to redirect_to(new_user_session_path)
        expect(delete :destroy, id: playlist.id).to redirect_to(new_user_session_path)
      end
      context 'with a public playlist' do
        let(:playlist) { FactoryGirl.create(:playlist, visibility: Playlist::PUBLIC) }
        it "should return the playlist view page" do
          expect(get :show, id: playlist.id).not_to redirect_to(new_user_session_path)
        end
      end
      context 'with a private playlist' do
        it "should NOT return the playlist view page" do
          expect(get :show, id: playlist.id).to redirect_to(new_user_session_path)
        end
      end
    end
    context 'with end-user' do
      before do
        login_as :user
      end
      it "all routes should redirect to /" do
        expect(get :edit, id: playlist.id).to redirect_to(root_path)
        expect(put :update, id: playlist.id).to redirect_to(root_path)
        expect(put :update_multiple, id: playlist.id).to redirect_to(root_path)
        expect(delete :destroy, id: playlist.id).to redirect_to(root_path)
      end
      context 'with a public playlist' do
        let(:playlist) { FactoryGirl.create(:playlist, visibility: Playlist::PUBLIC) }
        it "should return the playlist view page" do
          expect(get :show, id: playlist.id).not_to redirect_to(root_path)
        end
      end
      context 'with a private playlist' do
        it "should NOT return the playlist view page" do
          expect(get :show, id: playlist.id).to redirect_to(root_path)
        end
      end
    end
  end

  describe 'GET #index' do
    it 'assigns accessible playlists as @playlists' do
      # TODO: test non-accessible playlists not appearing
      playlist = Playlist.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:playlists)).to eq([playlist])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :show, { id: playlist.to_param }, valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
    # TODO: write tests for public/private playists
  end

  describe 'GET #new' do
    before do
      login_as :user
    end
    it 'assigns a new playlist as @playlist' do
      get :new, {}, valid_session
      expect(assigns(:playlist)).to be_a_new(Playlist)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :edit, { id: playlist.to_param }, valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Playlist' do
        expect do
          post :create, { playlist: valid_attributes }, valid_session
        end.to change(Playlist, :count).by(1)
      end

      it 'assigns a newly created playlist as @playlist' do
        post :create, { playlist: valid_attributes }, valid_session
        expect(assigns(:playlist)).to be_a(Playlist)
        expect(assigns(:playlist)).to be_persisted
      end

      it 'redirects to the created playlist' do
        post :create, { playlist: valid_attributes }, valid_session
        expect(response).to redirect_to(Playlist.last)
      end
    end

    context 'with invalid params' do
      before do
        login_as :user
      end
      it 'assigns a newly created but unsaved playlist as @playlist' do
        post :create, { playlist: invalid_attributes }, valid_session
        expect(assigns(:playlist)).to be_a_new(Playlist)
      end

      it "re-renders the 'new' template" do
        post :create, { playlist: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'POST #replicate' do
    before do
      login_as :user
    end
    let(:new_attributes) do
      { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, comment: Faker::Lorem.sentence, user: user }
    end
    let(:playlist) { FactoryGirl.create(:playlist, new_attributes) }

    context 'blank playlist' do
      it 'replicate a blank playlist' do
        post :replicate, format: 'json', old_playlist_id: playlist.id,
          playlist: { 'title' => playlist.title, 'comment' => playlist.comment, 'visibility' => playlist.visibility }
        expect(response.body).not_to be_empty
        parsed_response = JSON.parse(response.body)

        new_playlist = Playlist.find(parsed_response['playlist']['id'])

        expect(new_playlist.id).not_to eq playlist.id
        expect(new_playlist.user_id).to eq playlist.user_id
        expect(new_playlist.visibility).to eq playlist.visibility
        expect(new_playlist.title).to eq playlist.title
        expect(new_playlist.comment).to eq playlist.comment
      end
    end

    context 'non-blank playlist' do

      let(:media_object) { FactoryGirl.create(:media_object, visibility: 'public') }
      let!(:video_master_file) { FactoryGirl.create(:master_file, media_object: media_object, duration: "200000") }
      let!(:clip) { AvalonClip.create(master_file: video_master_file, title: Faker::Lorem.word,
        comment: Faker::Lorem.sentence, start_time: 1000, end_time: 2000) }
      let!(:playlist_item) { PlaylistItem.create!(playlist: playlist, clip: clip) }
      let!(:bookmark) { AvalonMarker.create(playlist_item: playlist_item, master_file: video_master_file, start_time: "200000")}

      it 'replicate playlist with items' do
        post :replicate, format: 'json', old_playlist_id: playlist.id,
          playlist: { 'title' => playlist.title, 'comment' => playlist.comment, 'visibility' => playlist.visibility }
        expect(response.body).not_to be_empty
        parsed_response = JSON.parse(response.body)

        new_playlist = Playlist.find(parsed_response['playlist']['id'])
        expect(new_playlist.items.count).to eq 1
        expect(new_playlist.clips.first.start_time).to eq clip.start_time
        expect(new_playlist.clips.first.id).not_to eq clip.id
        expect(new_playlist.items.first.id).not_to eq playlist_item.id
        expect(new_playlist.items.first.marker.count).to eq 1

      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, comment: Faker::Lorem.sentence }
      end

      it 'updates the requested playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: new_attributes }, valid_session
        playlist.reload
        expect(playlist.title).to eq new_attributes[:title]
        expect(playlist.visibility).to eq new_attributes[:visibility]
        expect(playlist.comment).to eq new_attributes[:comment]
      end

      it 'assigns the requested playlist as @playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: valid_attributes }, valid_session
        expect(assigns(:playlist)).to eq(playlist)
      end

      it 'redirects to edit playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: valid_attributes }, valid_session
        expect(response).to redirect_to(edit_playlist_path(playlist))
      end
    end

    context 'with invalid params' do
      it 'assigns the playlist as @playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: invalid_attributes }, valid_session
        expect(assigns(:playlist)).to eq(playlist)
      end

      it "re-renders the 'edit' template" do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: invalid_attributes }, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PUT #update_multiple' do
    context 'delete' do
      it 'redirects to edit playlist' do
        playlist = Playlist.create! valid_attributes
        put :update_multiple, { id: playlist.to_param, clip_ids: [] }, valid_session
        expect(response).to redirect_to(edit_playlist_path(playlist))
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested playlist' do
      playlist = Playlist.create! valid_attributes
      expect do
        delete :destroy, { id: playlist.to_param }, valid_session
      end.to change(Playlist, :count).by(-1)
    end

    it 'redirects to the playlists list' do
      playlist = Playlist.create! valid_attributes
      delete :destroy, { id: playlist.to_param }, valid_session
      expect(response).to redirect_to(playlists_url)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :edit, { id: playlist.to_param }, valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
  end

end
