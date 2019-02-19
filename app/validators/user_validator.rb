class UserValidator < ActiveModel::Validator
  def validate(record)
    if record.followers.include? record
      record.errors[:followers] << 'You can not have yourself as a follower of yourself'
    end

    if not record.is_author?
      record.errors[:following] << 'You can not subscribed to a non-author user'
    end

    follower_ids = record.follower_ids
    following_ids = record.following_ids

    if follower_ids.size != follower_ids.to_set.size
      follower_ids.detect do |id|
        if follower_ids.count(id) > 1
          record.errors[:followers] << "#{record.id} is already followed by user with id #{id}"
        end
      end
    end

    if following_ids.size != following_ids.to_set.size
      following_ids.detect do |id|
        if following_ids.count(id) > 1
          record.errors[:following] << "#{record.id} is already following the user with id #{id}"
        end
      end
    end

    if record.following.include? record
      record.errors[:following] << 'You can not follow your self'
    end
  end
end