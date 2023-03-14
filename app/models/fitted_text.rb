class FittedText
  attr_accessor :width, :text_size

  def initialize(width, text_size = BuckImage::FOR_POINT_SIZE)
    @width = width
    @text_size = text_size
  end

  def fit_text(text)
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

  private

  def text_fit?(text, width)
    tmp_image = Magick::Image.new(width, 500)
    drawing = MagickTextFactory.build(text_size)
    drawing.annotate(tmp_image, 0, 0, 0, 0, text)
    metrics = drawing.get_multiline_type_metrics(tmp_image, text)

    metrics.width < width
  end
end