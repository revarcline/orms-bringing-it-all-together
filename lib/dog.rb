# awooou (wolf howl)
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs'

    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    new(name: name, breed: breed).save
  end

  def self.find_by_id(num)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    new_from_db(DB[:conn].execute(sql, num)[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    AND breed = ?
    SQL
    dog_row = DB[:conn].execute(sql, name, breed)

    if !dog_row.empty?
      new_from_db(dog_row[0])
    else
      create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    if id
      update
    else
      sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?)'
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql, name, breed, id)
  end
end
