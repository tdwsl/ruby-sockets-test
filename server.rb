# sockets test in ruby

require 'socket'

port = 3000
server = TCPServer.new('localhost', port)

$threads = []
$to_close = []
$sessions = []
$emptying = false

def handle(session, ti)
  name = "you"
  while true
    got = session.gets
    puts "Recieved: #{got}"
    for i in 0 .. got.length-1
      print got[i].ord," "
    end
    puts

    while got[0].ord == 255
      got = got.slice(2, got.length)
    end

    strs = got.chomp.split(" ")
    if strs.length == 0
      continue
    end
    com = strs[0].downcase

    if com == ""
      break
    end

    puts "[#{com}]"

    if com == "quit"
      session.print "Bye-bye!\n"
      break
    elsif com == "hello"
      session.print "Hello there, #{name}!\n"
    elsif com == "name"
      if strs.length == 1
        name = "you"
        session.print "You now have no name.\n"
      else
        name = strs[1]
        session.print "Your name is now #{name}.\n"
      end
    elsif com == "help"
        session.print "quit, hello, name\n"
    else
      session.print "#{com} is not a valid command.\n"
    end
  end

  while true
    if not $emptying
      $emptying = true
    else
      continue
    end
    session.close
    $to_close += [$threads[ti]]
    $threads.delete $threads[ti]
    $sessions.delete session
    $emptying = false
    puts "closed connection #{ti}"
    break
  end
end

def update()
  while true
    sleep 5
    for s in $sessions
      s.print "The server loves you!\n"
    end
  end
end

uthr = Thread.new { update }

while session = server.accept
  $threads += [Thread.new { handle session, $threads.length-1 }]
  $sessions += [session]
  if $emptying
    continue
  end
  $emptying = true
  for t in $to_close
    t.join
  end
  $to_close = []
  $emptying = false
end

uthr.join
