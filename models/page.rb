
class Page
  include Mongoid::Document
  field :name
  field :time, :type => Integer
  field :body

  def to_hash
    {
      :name => name,
      :time => time,
      :body => body
    }
  end
end
