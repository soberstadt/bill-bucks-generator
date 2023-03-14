class Buck < ApplicationRecord
  attr_accessor :dept

  # validate so we don't count half-filled bills on stats
  validates :to, :from, presence: true

  def image_params
    {
      to: to,
      from: from,
      for_message: for_message,
      buck_type: buck_type,
      dept: dept
    }
  end

  def number
    buck_type == 'vonette' ? 5 : 1
  end
end
