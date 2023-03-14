class MagickTextFactory
  def self.build(pointsize)
    txt = Magick::Draw.new
    txt.pointsize = pointsize
    txt.gravity = Magick::NorthWestGravity
    txt
  end
end