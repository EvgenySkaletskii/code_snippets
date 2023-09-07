class AddIndexOnPatientIDInAppointments < ActiveRecord::Migration[6.0]
  def change
    add_index :appointments, :patient_id
  end
end

# При добавлении индекса postres залочит таблицу используя SHARE lock,
# который заблокирует добавление новых записей пока добавляется индекс.
# Это может вызвать задержку в зависимости от размера таблицы.

# Чтобы этого избежать нужно добавлять индекс со стратегией concurrently

class AddIndexOnPatientIDInAppointments < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
 
  def change
    add_index :appointments, :patient_id, algorithm: :concurrently
  end
end

# Нужно отключить транзакцию на добавление индекса (по умолчанию в rails она включена),
# т.к. postgres не разрешает добавлять индекс concurrently в транзакции

# Включить опцию algorithm: :concurrently

# можно использовать safe-pg-migrations gem
