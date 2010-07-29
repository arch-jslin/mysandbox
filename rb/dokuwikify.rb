
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
    str = "==== #{str[0..-2]} ====\n"
  elsif d =~ /^\"\(\\(xA4@|xA4G|xA4T|xA5\||xA4\\xAD|xA4\\xBB|xA4C|xA4K|xA4E|xA4Q)/
    str = "=== #{str[0..-2]} ===\n"
  elsif d =~ /^\"[0-9]\\xA1B/
    str = "  --#{str[2..-1]}"
  elsif d =~ /^\"\([0-9]/
    str = "    --#{str[3..-1]}"
  elsif d =~ /^\"[A-Z]\\xA1B/
    str = "      --#{str[2..-1]}"
  elsif d =~ /^\"\([A-Z]/
    str = "        --#{str[3..-1]}"
  elsif d =~ /^\"[a-z]\\xA1B/
    str = "          --#{str[2..-1]}"
  elsif d =~ /^\"\([a-z]/ 
    str = "            --#{str[3..-1]}"
  end
  str
end

def dokuwikify(str)
  str = remove_space(str)
  str = indent_with_list_identifier(str)
  str
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
    write_to_output(filename, str)
  else
    p "Unknown file."
  end
end

main ARGV[0]