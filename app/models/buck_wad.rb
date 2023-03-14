class BuckWad
  attr_reader :bucks
  attr_reader :from
  attr_reader :for_message
  attr_reader :to
  attr_reader :count
  attr_reader :dept

  def initialize(to: '', from: '', for_message: '', count: 1, dept: '')
    @from = from.to_s
    @to = to.to_s
    @for_message = for_message.to_s
    @dept = dept
    image_params = { to: to, from: from, for_message: for_message, dept: dept }
    count = count.to_i
    @count = count
    number_of_vonettes = count / 5
    number_of_bills = count % 5

    @bucks = []
    number_of_vonettes.times do
      @bucks << Buck.new(image_params.merge(buck_type: :vonette))
    end
    number_of_bills.times do
      @bucks << Buck.new(image_params.merge(buck_type: :bill))
    end
    add_pagination
  end

  def save
    bucks.all?(&:save)
  end

  def bucks_by_filename
    @bucks.map.with_index do |buck, i|
      [BuckImage.new(buck).filename(i), buck]
    end.to_h
  end

  private

  def add_pagination
    return unless @bucks.many?

    @bucks.each_with_index do |buck, i|
      buck.for_message = "#{buck.for_message} (#{i + 1}/#{@bucks.count})"
    end
  end
end
