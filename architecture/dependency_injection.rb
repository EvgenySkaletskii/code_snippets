# было - Reporter зависит от User т.к. знает его имя, метод и параметры

class Reporter
  def report
    user = User.new('Ivan')
    p user.name
  end
end

class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

# стало, Reporter зависит только от интерфейса name
# он может работать с объектами любых которые его реализуют

class Reporter
  attr_accessor :subject

  def initialize(subject)
    @subject = subject
  end

  def report
    p subject.name
  end
end

class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

user = User.new('Ivan')
Reporter.new(user).report
