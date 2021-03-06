# typed: true
class BillMailer < ApplicationMailer
  extend T::Sig

  sig do
    params(buck_wad: BuckWad, to_email: String, from_email: T.nilable(String))
      .returns(Mail::Message)
  end
  def bill(buck_wad:, to_email:, from_email: nil)
    @bucks = buck_wad.bucks_by_filename
    @bucks.each do |file_name, buck|
      attachments.inline[file_name] = buck.to_blob
    end
    mail(
      to: to_email,
      reply_to: from_email,
      subject: "You've got Bills (Bucks)"
    )
  end
end
