
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
    if str.size < 20 
	  str = "=== #{str[0..-2]} ===\n"   #Chinese (1~10
	else
	  str = "  --#{str[3..-1]}"         #But if it is too long (and usually there's no sub content) we use wiki list.
	end
  elsif d =~ /^\"[0-9]+\\xA1B/           
    str = "  --#{str[2..-1]}"           #digit followed by a chinese dot
  elsif d =~ /^\"\([0-9]+/
    str = "    --#{str[3..-1]}"         #enclosed digit 
  elsif d =~ /^\"[A-Z]\\xA1B/
    str = "      --#{str[2..-1]}"       #uppercase alphabet followed by a chinese dot
  elsif d =~ /^\"\([A-Z]/
    str = "        --#{str[3..-1]}"     #enclosed uppercase alphabet
  elsif d =~ /^\"[a-z]\\xA1B/
    str = "          --#{str[2..-1]}"   #lowercase alphabet followed by a chinese dot
  elsif d =~ /^\"\([a-z]/ 
    str = "            --#{str[3..-1]}" #enclosed lowercase alphabet
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
    if !(a[i][0] =~ /( |=)/)
	  if a[i-1] =~ /^ +-+/ && a[i-1].size < 15
	    a[i] = get_leading_space(a[i-1]) + ".." + a[i] + "\n"
      elsif a[i].size < 20
	    a[i-1].chop! #took out newline so this line will combine with last line
		a[i] += "\n"
	  else
	    last_leading = a[i-1] ? get_leading_space(a[i-1]) : ""
		next_leading = a[i+1] ? get_leading_space(a[i+1]) : ""
	    if last_leading.size > 0 && next_leading.size > 0
		  if last_leading.size == next_leading.size
		    a[i] = last_leading + ".." + a[i] + "\n"
		  else
		    a[i] = next_leading + ".." + a[i] + "\n"
		  end
		elsif last_leading.size > 0 || next_leading.size > 0
		  a[i] = (last_leading.size > 0 ? last_leading : next_leading) + ".." + a[i] + "\n"
		else
		  p a[i-1], a[i], a[i+1]
		  p "-------------------------"
		  a[i] += "\n"
        end
      end
	else
	  if a[i] =~ /^ +-+/
	    this_leading = get_leading_space(a[i])
		next_leading = get_leading_space(a[i+1])
		if next_leading.size > this_leading.size && this_leading.size < 5
		  a[i].gsub!(/( +-+)(.+)/) {|match|
		    if $2.size < 20
		      match = $1 + "**" + $2 + "**"
			else 
			  match
			end
		  }
		end
	  end
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