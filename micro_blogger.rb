require 'jumpstart_auth'
require 'bitly'
require 'klout'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
    Bitly.use_api_version_3
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def tweet(message)
    warning = "Warning! The tweet is longer than 140 characters!"
    if message.length() <= 140
      @client.update(message)
    else
      puts warning
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message

    screen_names = followers_list()
    if screen_names.include? target
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "Could not send the message, #{target} is not a follower!"
    end
  end

  def spam_my_followers(message)
    followers = followers_list()
    followers.each do |follower|
      dm(follower, message)
    end
  end

  def followers_list()
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
  end

  def everyones_last_tweet()
    friends = friends_list().sort_by{|friend| friend.screen_name.downcase}
    friends.each do |friend|
      timestamp = friend.status.created_at.strftime("%A, %b %d")
      puts "\n#{friend.screen_name} last said this on #{timestamp}:"
      puts "Last message: #{friend.status.text}"
    end
  end

  def friends_list()
    friends = @client.friends.collect{|friend| @client.user(friend)}
  end

  def shorten(original_url)
    bitley = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    shortened = bitley.shorten(original_url).short_url
    puts shortened
    return shortened
  end

  def klout_score()
    friends = friends_list()
    friends.each do |friend|
      puts "\nKlout score of #{friend.screen_name}:"
      identity = Klout::Identity.find_by_screen_name(friend.screen_name)
      user = Klout::User.new(identity.id)
      puts user.score.score
    end
  end

  def run
    command = ""
    while command != "q"
      printf "Enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
         when 'q' then puts "Goodbye!"
         when 't' then tweet(parts[1..-1].join(" "))
         when 'dm' then dm(parts[1], parts[2..-1].join(" "))
         when 'spam' then spam_my_followers(parts[1..-1].join(" "))
         when 'elt' then everyones_last_tweet()
         when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
         when 'klout' then klout_score()
         else
           puts "Sorry, I don't know how to #{command}"
      end
    end
  end

end

blogger = MicroBlogger.new
blogger.run