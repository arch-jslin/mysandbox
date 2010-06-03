class Hello {
  def hello(strings: String*): Seq[String] = {
    strings.map( (s:String) => s.toUpperCase() )
  }
}

object Hello2 {
  def hello(strings: String*) = strings.map( _.toUpperCase() )
}

val h = new Hello

Console.println( h.hello("hello, ", "world!") )
Console.println( Hello2.hello("nooo", "...ooOOO!!!") )