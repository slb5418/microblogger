require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
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
  	friends = @client.friends
  	friends.sort_by{|friend| friend.screen_name.downcase}
  	friends.each do |friend|
  	  timestamp = friend.status.created_at.strftime("%A, %b %d")
  	  puts "Screen name: #{friend.screen_name}"
  	  puts "Last message: #{friend.status.text}"
  	  puts ""
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
         else
           puts "Sorry, I don't know how to #{command}"
      end
    end
  end




end

blogger = MicroBlogger.new
blogger.run