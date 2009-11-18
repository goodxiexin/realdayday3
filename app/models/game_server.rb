class GameServer < ActiveRecord::Base

  belongs_to :game, :counter_cache => 'servers_count'

  belongs_to :area, :class_name => 'GameArea', :counter_cache => 'servers_count'

  has_many :game_characters, :foreign_key => 'server_id'
end
