require "sk_sdk/oauth"
require "sk_sdk/signed_request"

class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  # POST Receives the oauth code from SalesKing, saves it to session
  # renders canvas haml
  def create
    r = SK::SDK::SignedRequest.new(params[:signed_request], Sk::App.secret)
    raise "invalid SalesKing app signed-request #{r.data.inspect}" unless r.valid?
    # always save and set subdomain
    Sk::App.sub_domain = session['sub_domain'] = r.data['sub_domain']
    if r.data['user_id'] # logged in
      # new session with access_token, user_id, sub_domain
      session['access_token'] = r.data['access_token']
      session['user_id'] = r.data['user_id']
      session['company_id'] = r.data['company_id']
      session['language'] = find_locale(r.data['language'])
      redirect_to attachments_url
    else # must authorize redirect to oauth dialog
        render inline: "<script> top.location.href='#{Sk::App.auth_dialog}'</script>"
    end
  end

  #GET coming back from auth dialog as redirect_url
  def new
    if params[:code] # coming back from auth dialog as redirect_url
      Sk::App.sub_domain = session['sub_domain']
      Sk::App.get_token(params[:code])
      #redirect to sk internal canvas page, where we are now authenticated
      render inline: "<script> top.location.href='#{Sk::App.sk_canvas_url}'</script>"
    end
  end

  private

  def find_locale(locale)
    posix_match = locale.match(/\A(?<country>[a-z]{2})_[A-Z]{2}\Z/)
    posix_match.present? ? posix_match[:country] : locale
  end
end
