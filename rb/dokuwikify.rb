
require 'fileutils'

def write_to_output(filename, str)
  File.open("#{filename}_output.txt", "w") { |file| 
    file.syswrite(str)
  }
end

def remove_space(str)
  str2 = str.gsub(/(\¡@|[ \t\f])/, "") #Multi-byte space with ASCII spaces and tabs
  str2 ? str2 : str
end

def indent_with_list_identifier(str)
  d = str.dump
  if d =~ /^\"\\(xA4@|xA4G|xA4T|xA5\||xA4\\xAD|xA4\\xBB|xA4C|xA4K|xA4E|xA4Q)/
    str = "==== #{str[0..-2]} ====\n"   #Chinese 1~10
  elsif d =~ /^\"\(\\(xA4@|xA4G|xA4T|xA5\||xA4\\xAD|xA4\\xBB|xA4C|xA4K|xA4E|xA4Q)/
    str = "=== #{str[0..-2]} ===\n"     #Chinese (1~10
  else
    d.sub(/^\"(\(*)(\w+)/) { |m| 
      parenth = $1
      index = $2
      add_digit = $2.size > 1 ? 1 : 0
      substr = str[2+parenth.size+add_digit..-1];
      if parenth.size > 0
        case index
        when /[0-9]/ then str = "    --#{substr}"         #enclosed digit 
        when /[A-Z]/ then str = "        --#{substr}"     #enclosed uppercase alphabet
        when /[a-z]/ then str = "            --#{substr}" #enclosed lowercase alphabet
        else p "Something wrong when parsing list item. (1)"
        end
      else
        case index
        when /[0-9]/ then str = "  --#{substr}"           #digit followed by a chinese dot
        when /[A-Z]/ then str = "      --#{substr}"       #uppercase alphabet followed by a chinese dot
        when /[a-z]/ then str = "          --#{substr}"   #lowercase alphabet followed by a chinese dot
        else p "Something wrong when parsing list item. (2)"
        end
      end
    }
  end
  str
end

def dokuwikify(str)
  str = remove_space(str)
  str = indent_with_list_identifier(str)
  str
end

def get_leading_space(str)
  i = 0
  while str[i] == " "
    i += 1
  end
  " " * i
end

def post_modify(str)
  a = str.split("\n")
  result = ""
  a.size.times { |i|
    if !(a[i][0] =~ /( |=)/)                                      #if it is not a headline and not a list-item
      if a[i-1] =~ /^ +-+/ && a[i-1].size < 15                    #and the last line is very short
        a[i] = get_leading_space(a[i-1]) + ".." + a[i] + "\n"     #we assume it is a multi-line item to the last line
      elsif a[i].size < 20                                        #otherwise, if this line is very short
        a[i-1].chop!                                              #took out newline on last line so it will combine with last line
        a[i] += "\n"
      else                                                        #otherwise,
        last_leading = a[i-1] ? get_leading_space(a[i-1]) : ""   
        next_leading = a[i+1] ? get_leading_space(a[i+1]) : ""
        if last_leading.size > 0 && next_leading.size > 0         
          if last_leading.size == next_leading.size               #if next line and last line seems to be on the same level
            a[i] = last_leading + ".." + a[i] + "\n"              #we can pretty sure this multi-line item is on the same level
          else                                                    #as the last line (inner)
            a[i] = next_leading + ".." + a[i] + "\n"              #or we'll assume this line is on the same level as next line
          end                                                     #(probably outer)
        elsif last_leading.size > 0 || next_leading.size > 0
          a[i] = (last_leading.size > 0 ? last_leading : next_leading) + ".." + a[i] + "\n" #lastly, resolve to a valid one anyway
        else
          p a[i-1], a[i], a[i+1]                                  #and the process should not arrive at here.
          p "-------------------------"
          a[i] += "\n"
        end
      end
    else
      if a[i] =~ /^ +-+/                                          #on the other hand, 
        this_leading = get_leading_space(a[i])
        next_leading = get_leading_space(a[i+1])                  #we should make list items with its own sub items BOLD
        if next_leading.size > this_leading.size && this_leading.size < 5 
          a[i].gsub!(/( +-+)(.+)/) {|match|                       #so it stands out, but if the level is too deep don't do that
            if $2.size < 20                                       #and if it's a long line, don't do that too
              match = $1 + "**" + $2 + "**"
            else 
              match
            end
          }
        end
      end
      a[i].dump.sub(/^\"=== \((\\xA4@|\\xA4G|\\xA4T|\\xA5\||\\xA4\\xAD|\\xA4\\xBB|\\xA4C|\\xA4K|\\xA4E|\\xA4Q)(\\xA4@|\\xA4G|\\xA4T|\\xA5\||\\xA4\\xAD|\\xA4\\xBB|\\xA4C|\\xA4K|\\xA4E|\\xA4Q)*\)/) {
        flag = ($2 == nil)                                        # this is very bad method: now we try to make big items
        if a[i].size > 25 || !(a[i+1] =~ /^ +-+/)                 # with chinese numerical listing but without sub items
          if flag                                                 # to downgrade to normal list items. but I can only think of
            a[i] = "  --" + a[i][7..-4]                           # this stupid regexp to match multi-digit chinese numbers.
          else                                                    # the magical number 7 and 8 is the length to skip
            a[i] = "  --" + a[i][8..-4]                           # for different situations.
          end
        end
      }
      a[i] += "\n"
    end
  }
  result = a.join
end

def back_link
  "[[\xAF\xA7\xA5\xCD\xB2\xD5\xC2\xB4\xB3W\xBDd2010:\xAF\xA7\xA5\xCD\xB2\xD5\xC2\xB4\xB3\xB9\xB5{\xA8t\xB2\xCE\xAA\xED|\xA6^\xA8t\xB2\xCE\xAA\xED]]\n".force_encoding("Big5")
end

def main(filename)
  if FileTest.file?(filename)
    f = File.open(filename, "r")
    str = ""
    line = f.readline
    str += "===== #{line[0..-2]} =====\n" #special case: foremost title
    while !f.eof?
      line = f.readline
      str += dokuwikify(line)
    end
    str.squeeze!("\n")
    str = post_modify(str)
    str = back_link.encode + str + "\n====== ======\n" + back_link.encode
    write_to_output(filename, str)
  else
    p "Unknown file."
  end
end

main ARGV[0]