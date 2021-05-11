# rubocop:disable Lint/Void, Lint/ShadowingOuterLocalVariable
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :friendships
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id'

  def friends
    friends_array = friendships.map { |friendship| friendship.friend if friendship.confirmed }
    friends_array + inverse_friendships.map { |friendship| friendship.user if friendship.confirmed }
    friends_array.compact
  end

  # Users who have yet to confirme friend requests
  def pending_friends
    
    friendships.map { |friendship| friendship.friend unless friendship.confirmed }.compact
  end

  # Users who have requested to be friends
  def friend_requests
    #Friendship.where(friend_id: id, confirmed: false)
    inverse_friendships.map { |friendship| friendship.user unless friendship.confirmed }.compact
  end

  # To acept invitation to friendship
  def confirm_friend(user)
    friendship = inverse_friendships.find { |friendship| friendship.user == user }
    friendship.confirmed = true
    friendship.save
  end

  # To reject invitation to friendship
  def reject_friend(user)
    friendship = inverse_friendships.find { |friendship| friendship.user == user }
    friendship.destroy
  end

  # validate if user are already friends
  def friend?(user)
    friends.include?(user)
  end
end
# rubocop:enable Lint/Void, Lint/ShadowingOuterLocalVariable
