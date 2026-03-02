CreatorChannel.find_or_create_by!(handle: "@typecraft_dev") do |c|
  c.name = "Typecraft"
  c.youtube_channel_id = ""
  c.active = true
  c.niche_tags = %w[rails linux neovim bash homelab raspberrypi]
end

[
  {name: "Michael Reeves", handle: "@michaelreeves", youtube_channel_id: "UCtHaxi4GTYDpJgMSGy7AeSw"},
  {name: "NetworkChuck", handle: "@NetworkChuck", youtube_channel_id: "UC9x0AN7BWHpCDHSm9NiJFJQ"},
  {name: "Jeff Geerling", handle: "@geerlingguy", youtube_channel_id: "UCR-DXc1voovS8nhAvccRZhg"}
].each do |attrs|
  CreatorChannel.find_or_create_by!(handle: attrs[:handle]) do |c|
    c.name = attrs[:name]
    c.youtube_channel_id = attrs[:youtube_channel_id]
    c.active = true
    c.niche_tags = %w[raspberrypi homelab microcontroller builder]
  end
end
