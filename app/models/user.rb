require 'digest/sha1'

class User < ActiveRecord::Base

  has_one :profile, :dependent => :destroy

	# mails
	has_many :out_mails, :class_name => 'Mail', :foreign_key => 'sender_id', 
					 :conditions => { :delete_by_sender => false }, :order => 'created_at DESC'

  has_many :in_mails, :class_name => 'Mail', :foreign_key => 'recipient_id', 
					 :conditions => { :delete_by_recipient => false }, :order => 'created_at DESC'  

  def sent_mails
    mails = self.out_mails.group_by { |mail| mail.parent_id }
    mails.map do |parent_id, mail_array|
      mail_array.max {|a,b| a.created_at <=> b.created_at}
    end.sort {|a,b| b.created_at <=> a.created_at}
  end

  def recv_mails
    mails = self.in_mails.group_by { |mail| mail.parent_id }
    mails.map do |parent_id, mail_array|
      mail_array.max {|a,b| a.created_at <=> b.created_at}
    end.sort {|a,b| b.created_at <=> a.created_at }
  end

  def interested_in_game? game
		!game_attentions.find_by_game_id(game.id).nil?
  end

  has_many :friend_guesses,
           :dependent => :destroy

  def has_enough_friend_guesses
    self.friend_guesses.count > 40
  end

  has_many :guessed_friends,
           :class_name => 'User',
           :foreign_key => 'guess_id',
           :through => :friend_guesses,
           :uniq => true


  def destroy_existing_guesses
    unless self.friend_guesses.empty?
      FriendGuess.destroy_all(:user_id => self.id)
    end
  end

  def collect_friend_guesses(guessed_users)

    # go through all events find people that attending the same event as the current user
    # those users are most like to be friend with current user
    # event is not selected randomly because each new event is very likely bring people together
    self.events.each do |event|
      catch(:done) do
        event.confirmed_participants.each do |user|
          unless (self.id == user.id or self.has_potential_friend?(user))
            guessed_users[user.id] += 1
            throw :done if (guessed_users.size >= 200)
          end
        end
      end
    end

    # if friend's suggestion did not collect 200 samples from events
    # guild is considered for collecting friends' suggestion samples
    unless (guessed_users.size >= 200)
      self.guilds.each do |guild|
        catch(:done0) do
          guild.all_members.each do |user|
            unless (self.id == user.id or self.has_potential_friend?(user))
              guessed_user[user.id] += 1
              throw :done0 if (guessed_users.size >= 200)
            end
          end
        end
      end
    end

    # if events and guilds did no collect enough users then friends' friends are not collected.
    # otherwise, friends' friends are collected for consideration
    # friends' friends are selected randomly to avoid same users are used every time
    unless (guessed_users.size >= 200)
      catch(:done1) do 
        self.friends.each do |friend|
          @n = friend.friends.size
          @n.times do |i|
            @user_guess = friend.friends[rand(@n)]
            unless (self.id == @user_guess.id or self.has_potential_friend?(@user_guess))
              guessed_users[@user_guess.id] += 2
              throw :done1 if (guessed_users.size >= 200)
            end
          end
        end
      end
    end

    # if previous steps did not get enough users, all users in same servers are considered
    unless (guessed_users.size >= 200)
      catch(:done2) do
        self.characters.each do |each_character|
          @current_characters = each_character.server.game_characters.sort_by{rand}
          @current_characters.each do |other_character|
            unless (self.id == other_character.user.id or self.has_potential_friend?(other_character.user))
              guessed_users[other_character.user.id] += 1
              throw :done2 if (guessed_users.size >= 200)
            end
          end
        end
      end 
    end

    # At this stage, every user is needed for this engine
    # this only occur when user does not provide enough info or we have not get enough users
    unless (guessed_users.size >= 200)
      catch(:done3) do
        User.all.each do |each_user|
          guessed_users[each_user.id] += 1
          throw :done3 if (guessed_users.size >= 200)
        end
      end
    end
  end

  def calculating_final_scores(guessed_users, suggested_users)
    guessed_users.each_key do |user_id|
      this_user = User.find(user_id)

      suggested_users[user_id] += 2 * self.common_friends_with(this_user).count

      suggested_users[user_id] += 5 * self.common_guilds_with(this_user).count
 
      suggested_users[user_id] += 5 * self.common_events_with(this_user).count

      this_user.characters do |each_game_character|
        self.characters do |this_game_character|
          if (this_game_character.server.id == each_game_character.server.id)
            suggested_users[user_id] +=2
          end
        end
      end
    end
  end

  # this method has three main part
  # first part is to destroy all existing samples
  # second part is to collect 200 samples
  # third part is to calculate sample quality
  def create_friend_guesses
    self.destroy_existing_guesses

    @guessed_users = {}
    @guessed_users.default = 0
    self.collect_friend_guesses(@guessed_users)

    @suggested_users = @guessed_users
    @suggested_users.each_key do |user_id|
      @suggested_users[user_id] = 1
    end
    self.calculating_final_scores(@guessed_users, @suggested_users)

    @min_num = [50, @suggested_users.size].min
    @final_suggestions = @suggested_users.sort{|a,b| a[1] <=> b[1]}[0..@min_num]
    
    @final_suggestions.each do |element|
      self.friend_guesses.create(:guess_id => element[0])
    end
  end

  has_many :game_attentions

	has_many :interested_games, :through => :game_attentions, :source => :game

	# notifications
	has_many :notifications

	has_many :notices # comment, tag notices

	# pokes
	has_many :poke_deliveries, :foreign_key => 'recipient_id', :order => 'created_at DESC'

	# status
  has_many :statuses, :foreign_key => 'poster_id', :order => 'created_at DESC', :dependent => :destroy

	has_one :latest_status, :foreign_key => 'poster_id', :class_name => 'Status', :order => 'created_at DESC'

  # friend
	has_many :all_friendships, :class_name => 'Friendship'

  has_many :friendships, :dependent => :destroy, :conditions => {:status => 1}

	has_many :friends, :through => :friendships, :source => 'friend', :order => 'login ASC'

  def has_potential_friend? user
     all_friendships.find(:first, :conditions => {:friend_id => user.id}) or Friendship.find(:first, :conditions => {:friend_id => self.id, :user_id => user.id})
  end

  def has_friend? user
		all_friendships.find(:first, :conditions => {:friend_id => user.id, :status => 1})
  end

  def wait_for? user
		all_friendships.find(:first, :conditions => {:friend_id => user.id, :status => 0})
  end

	def common_friends_with user
		friends & user.friends
	end

  # profile
  has_one :profile, :dependent => :destroy

  # settings
	has_setting :application_setting

	has_setting :privacy_setting

	has_setting :mail_setting

  # game
  has_many :characters, :class_name => 'GameCharacter', :dependent => :destroy

  has_many :currently_playing_game_characters,
           :class_name => 'GameCharacter',                                    
           :conditions => { :playing => true },                               
           :order => 'created_at DESC' 

  has_many :games, :through => :characters, :uniq => true

	def has_same_game_with user
		games.each do |game|
			return true if user.games.include? game
		end
		return false
	end

  # album
  belongs_to :avatar

  has_one :avatar_album, :foreign_key => 'owner_id'

  has_many :albums, :class_name => 'PersonalAlbum', :foreign_key => 'owner_id', :order => 'uploaded_at DESC'

  # blogs
  has_many :blogs, :conditions => {:draft => false}, :order => 'created_at DESC', :dependent => :destroy, :foreign_key => :poster_id

  has_many :drafts, :class_name => 'Blog', :conditions => {:draft => true}, :order => 'created_at DESC', :dependent => :destroy, :foreign_key => :poster_id

  # videos
  has_many :videos, :order => 'created_at DESC', :dependent => :destroy, :foreign_key => :poster_id

  # events
  has_many :participations, :foreign_key => 'participant_id', :conditions => {:status => [3,4,5]} 

  has_many :events, :foreign_key => 'poster_id', :order => 'created_at DESC', :conditions => ["events.start_time >= ?", Time.now.to_s(:db)]

	with_options :order =>  'created_at DESC', :through => :participations, :source => :event do |user|

		user.has_many :upcoming_events, :conditions => ["events.start_time >= ?", Time.now.to_s(:db)]

		user.has_many :participated_events, :conditions => ["events.start_time < ?", Time.now.to_s(:db)]

	end

	def common_events_with user
		events & user.events
	end

  # polls
  has_many :votes, :foreign_key => 'voter_id'

  has_many :polls, :foreign_key => 'poster_id', :order => 'created_at DESC'

  has_many :participated_polls, :through => :votes, :uniq => true, :source => 'poll', :order => 'created_at DESC', :conditions => 'poster_id != #{id}'

	# guilds
	has_many :memberships

	with_options :through => :memberships, :source => :guild, :order => 'created_at DESC' do |user|

		user.has_many :guilds, :conditions => "memberships.status = 3"

		user.has_many :participated_guilds, :conditions => "memberships.status = 4 or memberships.status = 5"

		user.has_many :all_guilds, :conditions => "memberships.status IN (3,4,5)"

	end

	def common_guilds_with user
        all_guilds & user.all_guilds
	end

	# invitation and requests
	has_many :event_requests, :through => :events, :source => :requests

	has_many :event_invitations, :class_name => 'Participation', :foreign_key => 'participant_id', :conditions => {:status => 0}

	has_many :poll_invitations 

	has_many :guild_requests, :class_name => 'Membership', :foreign_key => 'president_id', :conditions => {:status => [1,2]}

	has_many :guild_invitations, :class_name => 'Membership',:conditions => {:status => 0}

	has_many :friend_requests, :class_name => 'Friendship', :foreign_key => 'friend_id', :conditions => {:status => 0}

	# tags
	has_many :friend_tags, :foreign_key => 'tagged_user_id'

	has_many :relative_blogs, :through => :friend_tags, :source => 'blog'

	has_many :relative_videos, :through => :friend_tags, :source => 'video'

	has_many :photo_tags, :foreign_key => 'tagged_user_id'

	has_many :relative_photos, :through => :photo_tags, :source => 'photo'

	# feeds
	has_many :feed_deliveries, :as => 'recipient', :order => 'created_at DESC'

	with_options :class_name => 'FeedDelivery', :as => 'recipient', :order => 'created_at DESC' do |user|
	
		user.has_many :status_feed_deliveries, :conditions => {:item_type => 'Status'}

		user.has_many :blog_feed_deliveries, :conditions => {:item_type => 'Blog'}

		user.has_many :video_feed_deliveries, :conditions => {:item_type => 'Video'}

		user.has_many :personal_album_feed_deliveries, :conditions => {:item_type => 'PersonalAlbum'}

		user.has_many :all_album_related_feed_deliveries, :conditions => {:item_type => ['EventAlbum', 'GuildAlbum', 'PersonalAlbum', 'Avatar']}

		user.has_many :poll_feed_deliveries, :conditions => {:item_type => 'Poll'}

		user.has_many :vote_feed_deliveries, :conditions => {:item_type => 'Vote'}

		user.has_many :all_poll_related_feed_deliveries, :conditions => {:item_type => ['Poll', 'Vote']}

		user.has_many :event_feed_deliveries, :conditions => {:item_type => 'Event'}

    user.has_many :participation_feed_deliveries, :conditions => {:item_type => 'Participation'} 

		user.has_many :all_event_related_feed_deliveries, :conditions => {:item_type => ['Event', 'Participation']}

		user.has_many :guild_feed_deliveries, :conditions => {:item_type => 'Guild'}
	
		user.has_many :membership_feed_deliveries, :conditions => {:item_type => 'Membership'}

		user.has_many :all_guild_related_feed_deliveries, :conditions => {:item_type => ['Guild', 'Membership']}	

	end

	has_many :feed_items, :through => :feed_deliveries, :order => 'created_at DESC'

	with_options :order => 'created_at DESC', :source => 'feed_item' do |user|
	
		user.has_many :status_feed_items, :through => :status_feed_deliveries

		user.has_many :blog_feed_items, :through => :blog_feed_deliveries

		user.has_many :video_feed_items, :through => :video_feed_deliveries

		user.has_many :event_feed_items, :through => :event_feed_deliveries

		user.has_many :participation_feed_items, :through => :participation_feed_deliveries

		user.has_many :all_event_related_feed_items, :through => :all_event_related_feed_deliveries

		user.has_many :guild_feed_items, :through => :guild_feed_deliveries

		user.has_many :membership_feed_items, :through => :membership_feed_deliveries

		user.has_many :all_guild_related_feed_items, :through => :all_guild_related_feed_deliveries

		user.has_many :poll_feed_items, :through => :poll_feed_deliveries

		user.has_many :vote_feed_items, :through => :vote_feed_deliveries

		user.has_many :all_poll_related_feed_items, :through => :all_poll_related_feed_deliveries

		user.has_many :all_album_related_feed_items, :through => :all_album_related_feed_deliveries

		user.has_many :personal_album_feed_items, :through => :personal_album_feed_deliveries
	
	end

	searcher_column :login

  attr_accessor :password, :password_confirmation

	attr_reader :enabled

  # callbacks
  before_save :encrypt_password
  before_create :make_activation_code

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :password, :password_confirmation, :gender

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token = nil
    save(false)
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end

  def has_role?(name)
    self.roles.find_by_name(name) ? true : false
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def recently_forgot_password?
    @forgotten_password
  end

  def recently_reset_password?
    @reset_password
  end

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = BetaInvitation.find_by_token(token)
  end

protected
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def set_invitation_limit
    self.invitation_limit = 5
  end   
 
end
