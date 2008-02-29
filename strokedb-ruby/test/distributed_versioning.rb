require 'test/environment.rb'

clear!

User = Meta.new do
  def on_pull_version(document)
    
  end
  def merge_versions(our, their)
    
  end
end

Playlist = Meta.new do
  def on_pull_version(document)
    
  end
  def merge_versions(our, their)
    
  end
end

Movie = Meta.new do
  def on_pull_version(document)
    
  end
  def merge_versions(our, their)
    
  end
end

oleg   = User.create!(:name => "Oleg",  :playlists => [])
yrashk = User.create!(:name => "Yurii", :playlists => [])

episode1 = Movie.create!(:owner => oleg,   :title => "Episode 1")
episode2 = Movie.create!(:owner => oleg,   :title => "Episode 2")
episode3 = Movie.create!(:owner => oleg,   :title => "Episode 3")
episode4 = Movie.create!(:owner => yrashk, :title => "Episode 4")

season1 = Playlist.create!(:title => "Californication. Season 1.", :items => [])
season1.items = [ episode1, episode2 ]
season1.save!
version = season1.__version__
puts "2-element version: #{version}"
season1.items << episode3
season1.save!
puts "3-element version: #{season1.__version__}"

oleg.playlists << season1
oleg.save!

# NOTE: reference is interpreted as a HEAD in case HEAD document is used

# In real app we fetch a copy via find anyway, 
# so there's no need in a special Document#clone
season1_clone = find(season1.uuid, version)
season1_clone.items << episode4
season1_clone.save!

yrashk.playlists << season1_clone.save!
yrashk.save!

episode5 = Movie.create!(:owner => yrashk, :title => "Episode 5")

yrashk.playlists[0].items << episode5
yrashk.playlists[0].save!  # TODO: Maybe, combine that in a one operation 
yrashk.save!               # (on_save callback in meta?)

# TODO: inspect a tree of Playlist versions

# TODO: merged_playlist = oleg.playlists.first.stroke_merge(yrashk.playlists.first)

save!

pp(Playlist.find.map do |d|
  "#{d.uuid} #{d.__version__}"
end)




