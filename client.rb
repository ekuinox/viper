#!/usr/bin/ruby
require 'net/imap'
require 'open-uri'

HOST = "imap.gmail.com"
PORT = 993

class IMAPClient
  @imap = nil

  def initialize(user, pass, label = "INBOX", debug = false)
    @user = user
    @pass = pass
    @label = label
    @debug = debug
    connect
  end

  def connect()
    @imap = Net::IMAP.new(HOST, PORT, true)
    @imap.login(@user, @pass)
    @imap.select(@label)
    puts "#{Time.now} connected to IMAP server"
  end

  def start
    last_id = nil
    begin
      @imap.idle do |resp|
        if resp.name == "EXISTS"
          last_id = resp.data
          @imap.idle_done
        end
      end
    rescue Net::IMAP::Error => e
      p e.inspect
      if e.inspect.include? "connection closed"
        puts "#{Time.now} connection closed: reconecting..."
        connect
      else
        tweet "unknown mail server error /"
        raise
      end
    end
    return last_id
  end


  def idle_done
    @imap.idle_done
  end

  def fetch_mail(range)
    begin
      mail = @imap.fetch(range, ["UID","BODY","BODY[1]","FLAGS", "ENVELOPE"])
      begin
        return mail
      rescue
        puts "failed to process mail: #$! at #$@"
      end
    rescue
      puts "failed to fetch mail: #$! at #$@"
    end

  end

  def process_mail(mail)
    seen = mail.attr["FLAGS"].include? :Seen
    from = mail.attr["ENVELOPE"].from[0]
    if (from.host == "nianticlabs.com" and from.mailbox == "ingress-support" and !seen) or @debug
      uid = mail.attr["UID"]
      body = mail.attr["BODY[1]"]
      if mail.attr["BODY"].multipart?
        n = mail.attr["BODY"].parts.map.with_index{|part,idx|
          idx if part.media_type == "TEXT" and part.subtype == "HTML"
        }.select{|x| x}[0]
        if not n
          raise "***NO HTML PART***"
        end
        if n != 0
          body = @imap.uid_fetch(uid, "BODY[#{n+1}]")[0].attr["BODY[#{n+1}]"]
        end
        if mail.attr["BODY"].parts[n].encoding == "QUOTED-PRINTABLE"
          body = body.unpack('M')[0]
        end
      end
      return body
    end
    return 0
  end

end
