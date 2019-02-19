class UserSubscriptionsListDto < BasePagedDto

  attr_accessor :following, :followers

  def initialize(user_relations, following, followers, relations_count, base_path, page, page_size)
    super(user_relations, relations_count, base_path, page, page_size)
    @following = following
    @followers = followers
  end
end