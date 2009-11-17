# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091108132558) do

  create_table "albums", :force => true do |t|
    t.string   "type"
    t.integer  "poster_id"
    t.integer  "owner_id"
    t.integer  "game_id"
    t.integer  "photos_count",   :default => 0
    t.integer  "privilege",      :default => 1
    t.integer  "cover_id"
    t.string   "title"
    t.text     "description"
    t.integer  "comments_count", :default => 0
    t.datetime "uploaded_at"
    t.datetime "created_at"
  end

  create_table "blogs", :force => true do |t|
    t.integer  "poster_id"
    t.integer  "game_id"
    t.string   "title",          :limit => 64
    t.text     "content",        :limit => 16777215
    t.integer  "digs_count",                         :default => 0
    t.integer  "comments_count",                     :default => 0
    t.integer  "tags_count",                         :default => 0
    t.boolean  "draft",                              :default => true
    t.integer  "privilege",                          :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string  "name"
    t.integer "region_id"
  end

  add_index "cities", ["region_id"], :name => "index_cities_on_region_id"

  create_table "comments", :force => true do |t|
    t.integer  "poster_id"
    t.integer  "recipient_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "digs", :force => true do |t|
    t.integer  "poster_id"
    t.integer  "diggable_id"
    t.string   "diggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", :force => true do |t|
    t.string  "name"
    t.integer "city_id"
  end

  add_index "districts", ["city_id"], :name => "index_districts_on_city_id"

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.integer  "poster_id"
    t.integer  "game_id"
    t.integer  "game_server_id"
    t.integer  "game_area_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "description"
    t.integer  "privilege",        :default => 1
    t.integer  "comments_count",   :default => 0
    t.integer  "invitees_count",   :default => 0
    t.integer  "requestors_count", :default => 0
    t.integer  "confirmed_count",  :default => 0
    t.integer  "maybe_count",      :default => 0
    t.integer  "declined_count",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_deliveries", :force => true do |t|
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.integer  "feed_item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_items", :force => true do |t|
    t.text     "data"
    t.string   "originator_type"
    t.integer  "originator_id"
    t.datetime "expired_at"
    t.datetime "created_at"
  end

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "topics_count",  :default => 0
    t.integer  "posts_count",   :default => 0
    t.integer  "guild_id"
    t.integer  "last_topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friend_tags", :force => true do |t|
    t.integer  "poster_id"
    t.integer  "tagged_user_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "friend_id"
    t.integer  "user_id"
    t.integer  "status"
    t.string   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_areas", :force => true do |t|
    t.string   "name"
    t.integer  "game_id"
    t.integer  "servers_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_attentions", :force => true do |t|
    t.integer "user_id"
    t.integer "game_id"
  end

  create_table "game_characters", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "server_id"
    t.integer  "area_id"
    t.integer  "profession_id"
    t.integer  "race_id"
    t.string   "name"
    t.integer  "level"
    t.boolean  "playing"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_professions", :force => true do |t|
    t.string   "name"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_races", :force => true do |t|
    t.string   "name"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_servers", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.integer  "game_id"
    t.integer  "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.string   "name"
    t.string   "official_web"
    t.string   "company"
    t.string   "agent"
    t.date     "sale_date"
    t.text     "description"
    t.float    "average_rating",    :default => 0.0
    t.boolean  "no_areas",          :default => false
    t.boolean  "no_races",          :default => false
    t.boolean  "no_professions",    :default => false
    t.integer  "areas_count",       :default => 0
    t.integer  "servers_count",     :default => 0
    t.integer  "professions_count", :default => 0
    t.integer  "races_count",       :default => 0
    t.integer  "attentions_count",  :default => 0
    t.integer  "ratings_count",     :default => 0
    t.integer  "comments_count",    :default => 0
    t.boolean  "stop_running",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guild_friendships", :force => true do |t|
    t.integer  "guild_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guilds", :force => true do |t|
    t.string   "name"
    t.integer  "game_id"
    t.string   "description"
    t.integer  "members_count",    :default => 0
    t.integer  "veterans_count",   :default => 0
    t.integer  "presidents_count", :default => 0
    t.integer  "invitees_count",   :default => 0
    t.integer  "requestors_count", :default => 0
    t.integer  "comments_count",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mails", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "delete_by_sender",    :default => false
    t.boolean  "delete_by_recipient", :default => false
    t.boolean  "read_by_recipient",   :default => false
    t.string   "title"
    t.text     "content"
    t.integer  "parent_id",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "guild_id"
    t.integer  "president_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moderator_forums", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "moderator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", :force => true do |t|
    t.integer  "producer_id"
    t.string   "producer_type"
    t.integer  "user_id"
    t.string   "data"
    t.boolean  "read",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.text     "data"
    t.integer  "user_id"
    t.string   "notifier_type"
    t.integer  "notifier_id"
    t.boolean  "read",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "event_id"
    t.integer  "status",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_tags", :force => true do |t|
    t.integer  "poster_id"
    t.integer  "photo_id"
    t.integer  "tagged_user_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "x"
    t.integer  "y"
    t.integer  "width"
    t.integer  "height"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.string   "type"
    t.integer  "digs_count",     :default => 0
    t.integer  "tags_count",     :default => 0
    t.integer  "comments_count", :default => 0
    t.integer  "album_id"
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "poster_id"
    t.text     "notation"
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poke_deliveries", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "poke_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pokes", :force => true do |t|
    t.string "name"
    t.string "path"
  end

  create_table "poll_answers", :force => true do |t|
    t.string   "description"
    t.integer  "poll_id"
    t.integer  "votes_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poll_invitations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "polls", :force => true do |t|
    t.string   "name"
    t.integer  "poster_id"
    t.integer  "game_id"
    t.text     "description"
    t.text     "explanation"
    t.integer  "max_multiple"
    t.date     "end_date"
    t.text     "summary"
    t.integer  "privilege",      :default => 2
    t.integer  "comments_count", :default => 0
    t.integer  "votes_count",    :default => 0
    t.integer  "voters_count",   :default => 0
    t.integer  "answers_count",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "forum_id"
    t.integer  "poster_id"
    t.text     "content"
    t.integer  "floor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "gender"
    t.integer  "region_id"
    t.integer  "city_id"
    t.integer  "district_id"
    t.integer  "qq"
    t.integer  "phone"
    t.string   "website"
    t.datetime "birthday"
    t.text     "about_me"
    t.integer  "comments_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating",        :default => 3
    t.integer  "rateable_id",                  :null => false
    t.string   "rateable_type",                :null => false
    t.integer  "user_id",       :default => 0, :null => false
    t.datetime "created_at"
  end

  add_index "ratings", ["rateable_id", "rating"], :name => "index_ratings_on_rateable_id_and_rating"

  create_table "regions", :force => true do |t|
    t.string "name"
  end

  create_table "sharings", :force => true do |t|
    t.integer  "shareable_id"
    t.string   "shareable_type"
    t.integer  "poster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.integer  "poster_id"
    t.text     "content"
    t.integer  "comments_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "poster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.string   "taggable_type"
    t.integer  "taggings_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "poster_id"
    t.string   "subject"
    t.text     "content"
    t.integer  "posts_count",  :default => 0
    t.boolean  "top",          :default => false
    t.integer  "last_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "gender"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code"
    t.datetime "activated_at"
    t.string   "password_reset_code"
    t.boolean  "enabled",                                 :default => false
    t.integer  "avatar_id"
    t.integer  "privacy_setting",           :limit => 8,  :default => 1441706
    t.integer  "mail_setting",              :limit => 8,  :default => 8796093022207
    t.integer  "application_setting",       :limit => 8,  :default => 65535
    t.integer  "friends_count",                           :default => 0
    t.integer  "personal_albums_count",                   :default => 0
    t.integer  "events_count",                            :default => 0
    t.integer  "upcoming_events_count",                   :default => 0
    t.integer  "past_events_count",                       :default => 0
    t.integer  "guilds_count",                            :default => 0
    t.integer  "participated_guilds_count",               :default => 0
    t.integer  "polls_count",                             :default => 0
    t.integer  "participated_polls_count",                :default => 0
    t.integer  "blogs_count",                             :default => 0
    t.integer  "drafts_count",                            :default => 0
    t.integer  "videos_count",                            :default => 0
    t.integer  "statuses_count",                          :default => 0
    t.integer  "requests_count",                          :default => 0
    t.integer  "invitations_count",                       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.integer  "poster_id"
    t.integer  "game_id"
    t.string   "title"
    t.string   "video_url"
    t.string   "embed_html"
    t.string   "thumbnail_url"
    t.integer  "digs_count",     :default => 0
    t.integer  "comments_count", :default => 0
    t.integer  "tags_count",     :default => 0
    t.integer  "privilege",      :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "visitor_records", :force => true do |t|
    t.integer  "visitor_id"
    t.integer  "profile_id"
    t.datetime "created_at"
  end

  create_table "votes", :force => true do |t|
    t.text     "answer_ids"
    t.integer  "voter_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
