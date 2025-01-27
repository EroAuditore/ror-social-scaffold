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
  # Users who have yet to confirme friend requests
  has_many :confirmed_friendships, -> { where confirmed: true }, class_name: 'Friendship'
  has_many :friends, through: :confirmed_friendships

  # Users who need to confirm friendship
  has_many :pending_friendships, -> { where confirmed: false }, class_name: 'Friendship', foreign_key: 'user_id'
  has_many :pending_friends, through: :pending_friendships, source: :friend

  # Users who requested to be friends (needed for notifications)
  has_many :inverted_friendships, -> { where confirmed: false }, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :friend_requests, through: :inverted_friendships, source: :user

  def friends
    friends_array = friendships.map { |friendship| friendship.friend if friendship.confirmed }
    friends_array + inverse_friendships.map { |friendship| friendship.user if friendship.confirmed }
    friends_array.compact
  end

  def friends_and_own(timeline_users)
    Post.where(user_id: timeline_users).ordered_by_most_recent.includes(:user)
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
