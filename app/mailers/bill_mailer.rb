class BillMailer < ApplicationMailer
  def bill(buck_wad:, to_email:, from_email:)
    @buck_wad = buck_wad
    bucks = buck_wad.bucks_by_filename
    bucks.each do |file_name, buck|
      image = BuckImage.new(buck)
      attachments.inline[file_name] = image.to_blob
    end
    @from_email = from_email

    @return_wad_params = {
      to: buck_wad.from,
      from: buck_wad.to,
      count: buck_wad.count,
      to_email: from_email,
      dept: buck_wad.dept
    }

    mail(to: to_email, reply_to: from_email, subject: subject(buck_wad))
  end

  private

  def subject(buck_wad)
    "Enclosed: Bill Bucks from #{buck_wad.from}! 🅱️💌"
  end
end
