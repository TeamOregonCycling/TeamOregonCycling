class PagesController < ApplicationController
  KNOWN_PAGES = %w[
    about_us
    sponsors
    code_of_conduct
    join_team
  ]

  def show
    page = params[:id].to_s
    if KNOWN_PAGES.include?(page)
      if respond_to?(page)
        send(page)
      else
        render action: page
      end
    else
      render_not_found!
    end
  end

  def about_us
    call_service(ListTeamLeaders) do |leaders|
      render action: :about_us, locals: { leaders: leaders }
    end
  end
end
