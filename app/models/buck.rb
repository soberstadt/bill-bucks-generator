# typed: strict
class Buck < ApplicationRecord # extra form inputs we don't care about
  extend T::Sig

  sig { returns(T.nilable(String)) }
  attr_accessor :dept

  TO_POINT_SIZE = 22
  FOR_POINT_SIZE = 25

  # validate so we don't count half-filled bills on stats
  validates :to, :from, presence: true

  sig { returns(String) }
  def to_blob
    build_image.to_blob
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def image_params
    {
      to: to,
      from: from,
      for_message: for_message,
      buck_type: buck_type,
      dept: dept
    }
  end

  sig { params(text: T.nilable(String), width: Integer).returns(String) }
  def fit_text(text, width)
    text = text.to_s
    return text if text.strip.blank?

    separator = ' '
    new_text = ''

    return text if text_fit?(text, width) || !text.include?(separator)

    # use / / to actually split on spaces, otherwise `split` will split on any whitespace
    words = text.split(/ /)
    words.each_with_index do |word, i|
      # no need to add white-space before the first word
      unless i == 0
        previous_line = new_text.split("\n").last || ''
        tmp_line = previous_line + separator + word

        # will the new word cause a wrap around
        if text_fit?(tmp_line, width)
          new_text += separator
        else
          new_text += "\n"
        end
      end
      new_text += word
    end
    new_text
  end

  sig { params(index: T.nilable(Integer)).returns(String) }
  def filename(index = nil)
    date = Date.today.strftime('%Y%m%d')
    date = date + index.to_s if index.present?
    "#{number}_#{to}_from_#{from}_#{date}.png"
  end

  sig { returns(Integer) }
  def number
    buck_type == 'vonette' ? 5 : 1
  end

  private

  sig { returns(Magick::ImageList) }
  def build_image
    img = T.unsafe(bill_or_vonette)

    to_text = text_instance
    to_text.pointsize = TO_POINT_SIZE
    img.annotate(to_text, 0, 0, 70, 300, to.to_s)
    img.annotate(to_text, 0, 0, 385, 300, from.to_s)

    wrapped_for_text = fit_text(for_message, 510)
    img.annotate(text_instance, 0, 0, 85, 350, wrapped_for_text)

    img.format = 'png'
    img
  end

  sig { returns(Magick::ImageList) }
  def bill_or_vonette
    if dept == 'irt'
      filename = buck_type == 'vonette' ? 'mag' : 'cap'
    else
      filename = buck_type == 'vonette' ? 'vonette' : 'bill'
    end
    Magick::ImageList.new("public/#{filename}.png")
  end

  sig { returns(Magick::Draw) }
  def text_instance
    txt = Magick::Draw.new
    txt.pointsize = FOR_POINT_SIZE
    txt.gravity = Magick::NorthWestGravity
    txt
  end

  sig { params(text: String, width: Integer).returns(T::Boolean) }
  def text_fit?(text, width)
    tmp_image = Magick::Image.new(width, 500)
    drawing = text_instance
    drawing.annotate(tmp_image, 0, 0, 0, 0, text)
    metrics = drawing.get_multiline_type_metrics(tmp_image, text)

    metrics.width < width
  end
end
