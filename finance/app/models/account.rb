class Account < ActiveRecord::Base
	has_many :statements
  attr_accessible :name
end
