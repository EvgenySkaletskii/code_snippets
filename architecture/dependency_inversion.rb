# Post и Comment - low level code, Moderator - high level code (зависит от Post и Comment)

class Post 
  attr_accessor :title, :body

  def initialize(title, body)
    @title = title
    @body = body
  end
end

class Comment
  attr_accessor :body

  def initialize(body)
    @body = body
  end
end

class Reporter
  def report_post(title, body)
    post = Post.new(title, body)

    p "New post: #{post.title} | #{post.body}"
  end

  def report_comment(body)
    comment = Comment.new(body)

    p "New comment: #{comment.body}"
  end
end

# теперь все классы зависят от интерфейса description
# Reporter принимает объект который этот интерфейс реализует

class Post 
  attr_accessor :title, :body

  def initialize(title, body)
    @title = title
    @body = body
  end

  def description
    "#{title} | #{body}"
  end
end

class Comment
  attr_accessor :body

  def initialize(body)
    @body = body
  end

  def description
    body
  end
end

class Reporter
  def report(obj)
    p "New #{obj.class.to_s.downcase}: #{obj.description}"
  end
end
