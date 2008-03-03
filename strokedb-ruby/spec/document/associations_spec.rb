require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Playlist.has_many :songs association" do
  
  before(:each) do
    setup_default_store
    setup_index
    Object.send!(:remove_const,'Playlist') if defined?(Playlist)
    Object.send!(:remove_const,'Song') if defined?(Song)
    Playlist = Meta.new do
      has_many :songs
    end
    Song = Meta.new
  end
  
  it "should convert :songs to Song and Playlist to playlist to compute foreign reference slot name" do
    playlist = Playlist.create!
    song = Song.create!(:playlist => playlist)
    playlist.songs.should == [song]
  end
  
end

describe "Playlist.has_many :rock_songs, :through => :songs, :conditions => { :genre => 'Rock' } association" do
  
  before(:each) do
    setup_default_store
    setup_index
    Object.send!(:remove_const,'Playlist') if defined?(Playlist)
    Object.send!(:remove_const,'Song') if defined?(Song)
    Playlist = Meta.new do
      has_many :rock_songs, :through => :songs, :conditions => { :genre => 'Rock' } 
    end
    Song = Meta.new
  end
  
  it "should convert :songs to Song and Playlist to playlist to compute foreign reference slot name" do
    playlist = Playlist.create!
    rock_song = Song.create!(:playlist => playlist, :genre => 'Rock')
    pop_song = Song.create!(:playlist => playlist, :genre => 'Pop')
    playlist.rock_songs.should == [rock_song]
  end
  
end

describe "Playlist.has_many :songs, :foreign_reference => :belongs_to_playlist association" do
  
  before(:each) do
    setup_default_store
    setup_index
    Object.send!(:remove_const,'Playlist') if defined?(Playlist)
    Object.send!(:remove_const,'Song') if defined?(Song)
    Playlist = Meta.new do
      has_many :songs, :foreign_reference => :belongs_to_playlist
    end
    Song = Meta.new
  end
  
  it "should convert :songs to Song and use foreign_reference to compute foreign reference slot name" do
    playlist = Playlist.create!
    song = Song.create!(:belongs_to_playlist => playlist)
    playlist.songs.should == [song]
  end
  
end

describe "Playlist.has_many :all_songs, :through => :songs association" do
  
  before(:each) do
    setup_default_store
    setup_index
    Object.send!(:remove_const,'Playlist') if defined?(Playlist)
    Object.send!(:remove_const,'Song') if defined?(Song)

    Playlist = Meta.new do
      has_many :all_songs, :through => :songs
    end
    Song = Meta.new
  end
  
  it "should use through's :songs to find out Song and convert Playlist to playlist" do
    playlist = Playlist.create!
    song = Song.create!(:playlist => playlist)
    playlist.all_songs.should == [song]
  end
  
end

describe "Playlist.has_many :authors, :through => [:songs,:authors] association" do
  
  before(:each) do
    setup_default_store
    setup_index
    Object.send!(:remove_const,'Playlist') if defined?(Playlist)
    Object.send!(:remove_const,'Song') if defined?(Song)

    Playlist = Meta.new do
      has_many :authors, :through => [:songs,:author]
    end
    Song = Meta.new
  end
  
  it "should use through's :songs to find out Song and convert Playlist to playlist" do
    playlist = Playlist.create!
    song = Song.create!(:playlist => playlist, :author => "John Doe")
    playlist.authors.should == [song.author]
  end

  it "should not fail if Song document has no :author slot" do
    pending
    playlist = Playlist.create!
    song = Song.create!(:playlist => playlist)
    playlist.authors.should be_empty
  end
  
  
  
end