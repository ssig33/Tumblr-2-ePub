class Entity < SimpleResource::Base
  include SimpleResource::MysqlEntityBackend
  include SimpleResource::MysqlIndexBackend
end
