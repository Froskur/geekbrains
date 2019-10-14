use vK;

# Ключики для таблицы профайлов 
ALTER TABLE profiles 
	ADD CONSTRAINT fk_profiles_user_id
		FOREIGN KEY (user_id) REFERENCES users(id)
	ON DELETE RESTRICT
	ON UPDATE RESTRICT;
	
ALTER TABLE profiles 
	ADD CONSTRAINT fk_profiles_photo_id
		FOREIGN KEY (photo_id) REFERENCES media(id)
	ON DELETE RESTRICT
	ON UPDATE RESTRICT;
	
ALTER TABLE profiles 
	ADD CONSTRAINT fk_profiles_regions_id
		FOREIGN KEY (region_id) REFERENCES regions(id)
	ON DELETE RESTRICT
	ON UPDATE RESTRICT;
	
# communities_users
ALTER TABLE communities_users
	ADD CONSTRAINT fk_communities_users_community_id
		FOREIGN KEY (community_id) REFERENCES communities(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_communities_users_user_id
		FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_communities_users_status_id
		FOREIGN KEY (status_id) REFERENCES communities_statuses(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT
;		
		
# communities		
ALTER TABLE communities
	ADD CONSTRAINT fk_communities_author_id
		FOREIGN KEY (author_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT
;		

# communities		
ALTER TABLE communities_users
	ADD CONSTRAINT fk_communities_users_author_id
		FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_communities_users_status_id
		FOREIGN KEY (status_id) REFERENCES communities_statuses(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT		
;		

# communities		
ALTER TABLE friendship
	ADD CONSTRAINT fk_friendship_user_id
		FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_friendship_friend_id
		FOREIGN KEY (friend_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_friendship_statuses_status_id
		FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT		
;	

# media		
ALTER TABLE media
	ADD CONSTRAINT fk_media_media_type_id
		FOREIGN KEY (media_type_id) REFERENCES media_types(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_media_user_id
		FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT		
;	

# media		
ALTER TABLE messages
	ADD CONSTRAINT fk_messages_from_user_id
		FOREIGN KEY (from_user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_messages_to_user_id
		FOREIGN KEY (to_user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT		
;	

# Posts
ALTER TABLE posts
	ADD CONSTRAINT fk_posts_user_id
		FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_posts_communitie_id
		FOREIGN KEY (communitie_id) REFERENCES communities(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT		
;	

# regions
ALTER TABLE regions
	ADD CONSTRAINT fk_regions_parent_id
		FOREIGN KEY (parent_id) REFERENCES regions(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT
;	
