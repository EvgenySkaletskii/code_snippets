## FIND_EACH
#взять всех <- плохая идея если таблица большая т.к. может переполнится память
User.all.each { ... }     #SELECT * FROM users

#взять всех пачками по 1000
User.find_each do |user|
  NewsMailer.weekly(user).deliver_now
end
#взять всех пачками по 1000, с 2000й по 10000ю запись *опции не обязательны
User.find_each(batch_size: 1000, start: 2000, finish: 10000) do |user|
  NewsMailer.weekly(user).deliver_now
end


## FIND_OR_CREATE_BY & FIND_OR_INITIALIZE_BY

Person.where(name: 'Spartacus', rating: 4)
# returns a chainable list (which can be empty).

Person.find_by(name: 'Spartacus', rating: 4)
# returns the first item or nil.

Person.find_or_initialize_by(name: 'Spartacus', rating: 4)
# returns the first item or returns a new instance (requires you call .save to persist against the database).

Person.find_or_create_by(name: 'Spartacus', rating: 4)
# returns the first item or creates it and returns it.

## FIRST_OR_CREATE & FIRST_OR_INITIALIZE

#take first from Foo with condition, otherwise create new record
Foo.where(something: value).first_or_create(name: '123', age: 14)
#initialize calls new instead of create


## N + 1
#11 запросов в DB, 1 для books и 10 для autors
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end

#includes
#2 запроса с includes
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end

#SQL
SELECT `books`.* FROM `books` LIMIT 10
SELECT `authors`.* FROM `authors`
  WHERE `authors.id` IN (1,2,3,4,5,6,7,8,9,10) # <= взято из author_ids из запроса#1

#модификации
Customer.includes(:orders, :reviews) #несколько связанных моделей
Author.includes(:books).where(books: { out_of_print: true }) #условие

# под капотом `includes` делегирует вызов одному из методов - `preload` или `eager_load` в зависимости от запроса пользователя:

# 1. По умолчанию используется `preload` (2 запроса в базу)
# 2. Если изначальный запрос содержит `where`, тогда используется `eager_load` (используя LEFT OUTER JOIN - 1 запрос)

#Их можно использовать самостоятельно, но preload нельзя использовать с where который ставит условия на связанную модель (т.к там 2 запроса). 
# where на ту же модель будет работать

Author.preload(:books).where('book.rating > 5') #не будет работать
Author.preload(:books).where('author.age >50')  #будет работать

## JOINS VS INCLUDES

# Используй joins когда тебе нужно отфильтровать записи по условию из связанной таблицы
authors = Author.joins(:books).where('book.rating > 5')

# Используй includes тебе нужен доступ к данным из связанной модели
authors = Author.includes(:books)
author.each do |author|
	result << author.books
end

## PLUCK
Person.pluck(:name)
# SELECT people.name FROM people
# => ['David', 'Jeremy', 'Jose']

Person.pluck(:id, :name)
# SELECT people.id, people.name FROM people
# => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]

Person.distinct.pluck(:role)
# SELECT DISTINCT role FROM people
# => ['admin', 'member', 'guest']

Person.where(age: 21).limit(5).pluck(:id)
# SELECT people.id FROM people WHERE people.age = 21 LIMIT 5
# => [2, 3]

#pluck with SQL
Person.pluck('DATEDIFF(updated_at, created_at)')
# SELECT DATEDIFF(updated_at, created_at) FROM people
# => ['0', '27761', '173']


## TRANSACTIONS

#через ActiveRecord::Base class
ActiveRecord::Base.transaction do
  @new_user = User.create(user_params)
  raise ActiveRecord::RecordInvalid unless @new_user.persisted?
  ...
end

#у каждой модели есть метод transaction
Transfer.transaction do
  ...
end

#и даже у каждого объекта из модели
transfer = Transfer.new(...)
transfer.transaction do
  ...
end

## RACE CONDITIONS & LOCKS

class Product < ApplicationRecord
	#product.quantity - кол-во товаров
end
	
#где-то в коде
def buy(value)
	product = Product.find(1)
	product.quantity -= value
	product.save
end

#запрос 1 вызывает buy с value 10
#запрос 2 вызывает buy с value 5
#запрос 1 найдёт product и получит quantity 100
#запрос 2 найдёт product и получит quantity 100
#запрос 1 поменяет quantity на 90 и сохранит
#запрос 2 поменяет quantity на 95 и сохранит
#оба запроса выполнены, но quantity = 95 а не 85

# Optimistic locks
# Для того чтобы включить нужно создать в модели колонку lock_version

def buy(value)
	product = Product.find(1)
	product.quantity -= value
	product.save
end

#запрос 1 вызывает buy с value 10
#запрос 2 вызывает buy с value 5
#запрос 1 найдёт product и получит quantity 100
#запрос 2 найдёт product и получит quantity 100
#запрос 1 поменяет quantity на 90 и сохранит

#запрос 2 попытается сохранить но получит 
#Attempted to update a stale object: Job. (ActiveRecord::StaleObjectError)

# Pessimistic locks
def buy(value)
	product = Product.find(1)
	product.with_lock do
		product.quantity -= value
		product.save
	end
end

#запрос 1 выполняет операции над product
#запрос 2 ждёт освобождения ресурса


#Agregation functions

# SELECT AVG(age) FROM users
User.average(:age) 

#SELECT COUNT(*) FROM users
User.count

#SELECT MAX(users.age) FROM users
User.maximum(:age) # => 93
#SELECT MIN(users.age) FROM users
User.minimum(:age) # => 7

#SELECT SUM(user.age) FROM users
User.sum(:age) # => 4562

# SELECT users.id FROM users
User.ids 

# SELECT users.name FROM users
User.pluck(:name) # => ['David', 'Jeremy', 'Jose']
