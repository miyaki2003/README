class LineUser < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[line]
end