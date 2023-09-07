### EXPLAIN

#To view raw SQL code run `explain` command.
#Explain также работает с SELECT, DELETE, INSERT, REPLACE и UPDATE

User.where(first_name: 'John').explain

EXPLAIN for: SELECT "users".* FROM "users" WHERE "users"."first_name" = $1 [["first_name", "John"]]
                        QUERY PLAN
----------------------------------------------------------
 Seq Scan on users  (cost=0.00..914.38 rows=1 width=1201)
   Filter: ((first_name)::text = 'John'::text)
(2 rows)


#Когда в explain фигурирует Seq Scan - мы сканируем всю таблицу (возможно тут имеет место добавления индекса)

### INCLUDES

users = User.where(status: 'active').includes(:projects)

users.each do |user|
	p "#{user.name}: #{user.project}"
end

#будет всего 2 запроса
#первый - выбрать пользователей
#второй - выбрать projects где id пользователя это ids из первого запроса


### INDEXES

#миграция для простого индекса
class AddIndexOnProjectToUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :project
  end
end

#миграция для составного индекса
class AddIndexOnProjectAndCountryToUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :users, [:project, :country]
  end
end

#теперь такой запрос будет выполняться намного быстрее
User.where(project: "abc", country: "Germany")


### LIMITS

#никогда не далей так
User.where(country: "Germany").each do |user|
  puts user
end

#лучше так - батчи будут по 1000 записей
User.where(country: "Germany").find_each do |user|
  puts user
end

#или так если нужно выбрать больше
User.where(country: "Germany").find_each(:batch_size: 5000)


### PLUCK & IDS

User.ids
User.pluck(:name, :age)


### BULK OPERATIONS

#DELETION
#не делай так
users = User.where(country: "Germany")
 
users.each do |user|
  user.delete
end
 
# >
# DELETE FROM users WHERE id = 1;
# DELETE FROM users WHERE id = 5;

#делай так

users = User.where(country: "Germany")
users.delete_all

# >
# DELETE FROM users WHERE users.country = 'Germany';


### CREATION
users = [
  {name: "Milap", email: "milap@country.com", country: "Germany"},
  {name: "Aastha", email: "aastha@country.com", country: "Germany"}
]
 
User.create(users)
 
# INSERT INTO users (name, email)
# VALUES
#   ('Milap', 'milap@country.com', 'Germany'),
#   ('Aastha', 'aastha@country.com', 'Germany')

