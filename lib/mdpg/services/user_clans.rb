# frozen_string_literal: true

class UserClans < Struct.new(:user)
  def clan_ids_and_names_sorted_by_name
    clan_ids_and_names.sort { |a, b| a[1] <=> b[1] }
  end

  private def clan_ids_and_names
    clans.map { |x| [x.id, x.name] }
  end

  private def clans
    user.clan_ids.map { |x| Clan.find(x) }
  end
end
