
class Page
  include Mongoid::Document
  field :name
  field :time, :type => Integer
  field :lines, :type => Array

  def to_hash
    h = {
      :name => name,
      :time => time,
      :lines => lines
    }
    h[:lines] = ["(empty)"] unless lines
    return h
  end
end
