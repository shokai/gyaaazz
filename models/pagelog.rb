
class PageLog
  include Mongoid::Document
  field :name
  field :time, :type => Integer
  field :lines, :type => Array

  def to_hash
    {
      :name => name,
      :time => time,
      :lines => lines
    }
  end
end
