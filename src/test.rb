require "tokenizer.rb"
require "parser.rb"

code =
"array[4 * x] = func(23, Foo.otherFunc(n + 1) - 5) "
puts("=Code=\n#{code}\n")

tokenizer = Tokenizer.new(code)
tokens = tokenizer.tokenize()
puts("=Tokens=")
for token in tokens
    puts("#{token.line+1}: #{token.type.name}: #{token.data}")
end

parser = Parser.new(tokens)
tree = parser.parse()
puts("\n=AST=\n#{tree}")