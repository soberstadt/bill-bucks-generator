class BuckImage
  TO_POINT_SIZE = 22
  FOR_POINT_SIZE = 25

  attr_accessor :buck

  delegate :to, :from, :for_message, :buck_type, :dept, to: :buck

  def initialize(buck)
    @buck = buck
  end

  def to_blob
    build_image.to_blob
  end

  def filename(index = nil)
    date = Date.today.strftime('%Y%m%d')
    date = date + index.presence.to_s
    "#{buck.number}_#{to}_from_#{from}_#{date}.png"
  end

  private

  def fit_text(text, width)
    FittedText.new(width).fit_text(text)
  end

  def build_image
    img = image_base

    to_text = MagickTextFactory.build(TO_POINT_SIZE)
    img.annotate(to_text, 0, 0, 70, 300, to.to_s)
    img.annotate(to_text, 0, 0, 385, 300, from.to_s)

    wrapped_for_text = fit_text(for_message, 510)
    for_text = MagickTextFactory.build(FOR_POINT_SIZE)
    img.annotate(for_text, 0, 0, 85, 350, wrapped_for_text)

    img.format = 'png'
    img
  end

  def image_base
    if dept == 'irt'
      filename = buck_type == 'vonette' ? 'mag' : 'cap'
    else
      filename = buck_type == 'vonette' ? 'vonette' : 'bill'
    end
    Magick::ImageList.new("public/#{filename}.png")
  end
end