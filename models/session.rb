require 'rubygems'
require 'active_record'

class Session < ActiveRecord::Base
  serialize :data
end
