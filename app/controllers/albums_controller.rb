# -*- encoding : utf-8 -*-
# The business logic for song albums.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)
 
class AlbumsController < ApplicationController
	include ImageableController

	before_action :set_resource, only: [ :show, :edit, :update, :destroy ]
	before_action :ensure_admin, only: [ :edit, :update, :destroy ]
	oauthenticate interactive: true, except: [ :index, :show ]
	respond_to :html, :embedded, :xml, :json
	
	# GET /albums
	def index
		l, o = pagination_params
		@recent = Listen.order(created_at: :desc).where(:album).limit(l).offset(o).map(&:album)
		@weekly = Album.top(from: 7.days.ago).limit(l).offset(o)
		@all_time = Album.top.limit(l).offset(o)
		
		if user_signed_in?
			@user_recent = current_user.listens.order(created_at: :desc).where(:album).limit(l).offset(o).map(&:album)
			@user_weekly = Album.top(for: current_user, from: 7.days.ago).limit(l).offset(o)
			@user_all_time = Album.top(for: current_user).limit(l).offset(o)
		end
		
		respond_with(@all_time)
	end
	
	# GET /albums/by/1
	def by
		l, o = pagination_params
		@artist = Artist.find(params[:artist_id])
		@albums = @artist.albums.limit(l).offset(o)
		respond_with(@albums)
	end

	# GET /albums/1
	def show
		l, o = pagination_params
		@album.paginate_songs(l, o)
		respond_with(@album, methods: [ :paginated_songs ])
	end

	# GET /albums/1/edit
	def edit
		render layout: false
	end

	# PATCH /albums/1
	def update
		if params[:songs].present?
			
			# add songs
			if params[:songs][:added].present?
				params[:songs][:added].each do |s|
					song = Song.get(current_user, s)
					@album.songs << song if song and not @album.songs.include?(song)
				end
			end
			
			# remove songs
			if params[:songs][:removed].present?
				params[:songs][:removed].each do |s|
					song = Song.find(s.to_i) if s.to_i > 0
					@album.songs.delete(song) if song
				end
			end
			
			params.delete(:songs)
		end
		
		success = params[:album].present? ? @album.update_attributes(album_params) : true
		
		respond_to do |format|
			if success
				format.html { redirect_to @album }
				format.js { }
				format.json { render json: @album, location: @album }
			else
				format.html { render action: 'edit' }
				format.js { render partial: 'shared/dialog/errors', locals: { resource: @album, action: :update } }
				format.json { render json: @album.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /albums/1
	def destroy
		@album.destroy
		respond_with @album
	end
	
	private

	# Use callbacks to share common setup or constraints between actions.
	def set_resource
		not_found('album') and return unless Album.exists? params[:id]
		@album = Album.find(params[:id])
	end
	
	# Access the resource for this controller.
	def resource
		@album
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def album_params
		params.require(:album).permit(:title)
	end
end
