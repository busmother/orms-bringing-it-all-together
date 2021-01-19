require 'pry'
class Dog
    attr_accessor :name, :breed, :id

    def initialize (id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql, @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        end
        self
    end

    def self.create(hash)
        new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
        new_dog.save
    end

    def self.new_from_db(row)
        new_dog = Dog.new(id:row[0],name:row[1],breed:row[2])
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        search = DB[:conn].execute(sql, id)
        new_from_db(search[0])
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
        if dog == []
            dog = Dog.new(name:hash[:name],breed:hash[:breed])
            dog.save
        else
            self.new_from_db(dog[0])
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
        #binding.pry
        search = DB[:conn].execute(sql, name)
        self.new_from_db(search[0])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, @name, @breed, @id)
    end

end