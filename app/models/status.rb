class Status < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'Ready' },
    { id: 2, name: 'Todo' },
    { id: 3, name: 'Done' }
  ]

  enum_accessor :name
end
