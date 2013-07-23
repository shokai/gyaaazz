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
    h[:lines] = ["(empty)"] if !lines or lines.length < 1
    return h
  end
end
