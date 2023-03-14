class BucksController < ApplicationController
  def generate
    validate_email_requirements if send_email?
    redirect_to_new and return if flash[:error].present?
    send_email if send_email?

    bill_counter if build_wad.save
    save_from_to_session

    redirect_to_new
  end

  def new
    @wad = build_wad
  end

  def img
    image = BuckImage.new(build_buck)
    send_data image.to_blob,
              filename: image.filename,
              type: 'image/png',
              disposition: 'inline'
  end

  private

  def send_email?
    params[:commit].to_s == 'Send Email'
  end

  def redirect_to_new
    new_params = %i[to from for_message count dept to_email]
    redirect_to bucks_new_path(params: wad_params.slice(*new_params))
  end

  def validate_email_requirements
    if helpers.current_user.blank?
      flash[:error] = 'You must be logged in to send emails'
    elsif !EmailValidator.cru?(wad_params[:to_email])
      flash[:error] = 'You may only send emails to Cru email addresses'
    end
  end

  def send_email
    BillMailer.bill(
      buck_wad: build_wad,
      to_email: wad_params[:to_email].to_s,
      from_email: helpers.current_user.email
    ).deliver_now
    flash[:notice] = 'Email successfully sent!'
  end

  def build_wad
    @wad ||=
      BuckWad.new(**wad_params.slice(:to, :from, :for_message, :count, :dept))
  end

  def build_buck
    @buck ||= Buck.new(image_params)
  end

  def wad_params
    return @wad_params if @wad_params
    @wad_params =
      params
        .permit(:to, :from, :for_message, :count, :commit, :dept, :to_email)
        .to_h
        .except(:commit)
        .symbolize_keys

    # maintain support for old links (since we have asked people to send us bills in the past)
    @wad_params[:count] = 5 if params[:buck_type].in?(%w[vonette mag])
    @wad_params
  end

  def image_params
    return @image_params if @image_params
    @image_params =
      params
        .permit(:to, :from, :for_message, :buck_type, :commit, :format, :dept)
        .to_h
        .except(:commit, :format)
  end

  def bill_counter
    session[:bill_count] = 0 if session[:bill_count].nil? || new_quarter?
    session[:bill_count] += wad_params[:count].to_i

    session[:last_creation] = Date.today
  end

  def new_quarter?
    return false unless session[:last_creation]

    previous_entry = session[:last_creation].to_date
    current_quarter_start = Date.today.beginning_of_quarter
    previous_entry < current_quarter_start
  end

  def save_from_to_session
    session[:previous_from] = wad_params[:from]
  end
end
