class ListTeamLeaders < ApplicationService
  authorization_policy allow_all: true

  main do
    self.result = User
                  .where(team_leader: true)
                  .order(:last_name, :first_name)
                  .readonly
                  .all
  end
end
