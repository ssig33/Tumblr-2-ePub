class Sql < ActiveRecord::Base
  def self.do_sql (sql)
    puts sql
    return connection.execute(sql)
  rescue => e
    puts e
  end
end
