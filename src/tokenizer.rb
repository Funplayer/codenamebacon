# Tokenizing exception catch for invalid tokens. #
class TokenException < Exception
	
	def initialize(column, line, string)
		super("Token error at line " + line.to_s + ", column" + column.to_s + ": " + message)
	end
	
end

# ------------------- #
# class TokenCategory #
# ------------------------------------------- #
# Contains the constants for the token types. #
# ------------------------------------------- #
class TokenCategory
	IDENTIFIER = 1
	KEYWORD = 2
	OPERATOR = 3
	LITERAL = 4
end

# --------------- #
# class TokenType #
# ------------------------------------------------- #
# Initializing this will create a TokenType object, # 
# storing the token into the "Tokens" class.        #
# ------------------------------------------------- #
class TokenType
	attr_accessor :type
	attr_accessor :name
	attr_accessor :match
	def initialize(type, name, match = nil)
		@type = type
		@name = name
		@match = match
		# If match is not nil
		if !@match.nil?
			# If type is a keyword
			if @type == TokenCategory::KEYWORD
				# write to the keyword at match position
				Tokens::KEYWORDS[match] = self
			# If type is an operator
			elsif @type == TokenCategory::OPERATOR
				# write to the operator at match position
				Tokens::OPERATORS[match] = self
			end
		end
	end
end

# ------------ #
# class Tokens #
# ---------------------------------------------------- #
# Contains constants of TokenType initialized classes. #
# ---------------------------------------------------- #
class Tokens
	KEYWORDS = {}
	OPERATORS = {}
	#Identifier	= Class.new(type, "NAME", "match")
	IDENT	 	= TokenType.new(TokenCategory::IDENTIFIER, "IDENTIFIER", nil)
	
	# Keywords #
	CLASS		= TokenType.new(TokenCategory::KEYWORD, "CLASS", 	"class")
	DO			= TokenType.new(TokenCategory::KEYWORD, "DO", 		"do")
	IF			= TokenType.new(TokenCategory::KEYWORD, "IF",		"if")
	ELSE		= TokenType.new(TokenCategory::KEYWORD, "ELSE",		"else")
	ELSEIF		= TokenType.new(TokenCategory::KEYWORD, "ELSEIF",	"elseif")
	THEN		= TokenType.new(TokenCategory::KEYWORD, "THEN",		"then")
	WHILE		= TokenType.new(TokenCategory::KEYWORD, "WHILE",	"while")
	LOOP		= TokenType.new(TokenCategory::KEYWORD, "LOOP",		"loop")
	FOR			= TokenType.new(TokenCategory::KEYWORD, "FOR", 		"for")
	UNTIL		= TokenType.new(TokenCategory::KEYWORD, "UNTIL",	"until")
	BREAK		= TokenType.new(TokenCategory::KEYWORD, "BREAK",	"break")
	RETURN		= TokenType.new(TokenCategory::KEYWORD, "RETURN", 	"return")
	OR			= TokenType.new(TokenCategory::KEYWORD,	"OR",		"or")
	AND			= TokenType.new(TokenCategory::KEYWORD, "AND",		"and")
	NOT			= TokenType.new(TokenCategory::KEYWORD, "NOT",		"not")
	BEGIN_		= TokenType.new(TokenCategory::KEYWORD, "BEGIN",	"begin")
	RESCUE		= TokenType.new(TokenCategory::KEYWORD,	"RESCUE",	"rescue")
	END_		= TokenType.new(TokenCategory::KEYWORD, "END",		"end")
	
	# Operators #
	PLUS		= TokenType.new(TokenCategory::OPERATOR, "PLUS",		"+")
	MINUS		= TokenType.new(TokenCategory::OPERATOR, "MINUS",		"-")
	MULT		= TokenType.new(TokenCategory::OPERATOR, "MULT",		"*")
	DIV			= TokenType.new(TokenCategory::OPERATOR, "DIV",			"/")
	GREATER		= TokenType.new(TokenCategory::OPERATOR, "GREATER",		">")
	LESS		= TokenType.new(TokenCategory::OPERATOR, "LESS",		"<")
	MODULO		= TokenType.new(TokenCategory::OPERATOR, "MODULO",		"%")
	INC 		= TokenType.new(TokenCategory::OPERATOR, "INC",			"++")
	DEC 		= TokenType.new(TokenCategory::OPERATOR, "DEC",			"--")
	PLUS_EQUAL	= TokenType.new(TokenCategory::OPERATOR, "PLUS_EQUAL",	"+=")
	MINUS_EQUAL	= TokenType.new(TokenCategory::OPERATOR, "MINUS_EQUAL",	"-=")
	MULT_EQUAL	= TokenType.new(TokenCategory::OPERATOR, "MULT_EQUAL",	"*=")
	DIV_EQUAL	= TokenType.new(TokenCategory::OPERATOR, "DIV_EQUAL",	"/=")
	EQUAL		= TokenType.new(TokenCategory::OPERATOR, "EQUAL",		"=")
	EQUALS 		= TokenType.new(TokenCategory::OPERATOR, "EQUALS", 		"==")
	INEQUAL   	= TokenType.new(TokenCategory::OPERATOR, "INEQUAL",		"!=")	
	GREATEQUAL  = TokenType.new(TokenCategory::OPERATOR, "GREATEQUAL",	">=")
	LESSEQUAL   = TokenType.new(TokenCategory::OPERATOR, "LESSEQUAL",	"<=")
	LBRACE		= TokenType.new(TokenCategory::OPERATOR, "LBRACE",		"{")
	RBRACE		= TokenType.new(TokenCategory::OPERATOR, "RBRACE",		"}")
	LBRACKET	= TokenType.new(TokenCategory::OPERATOR, "LBRACKET",	"[")
	RBRACKET	= TokenType.new(TokenCategory::OPERATOR, "RBRACKET",	"]")
	LPAREN  	= TokenType.new(TokenCategory::OPERATOR, "LPAREN",		"(")
	RPAREN  	= TokenType.new(TokenCategory::OPERATOR, "RPAREN",		")")
	PERIOD  	= TokenType.new(TokenCategory::OPERATOR, "PERIOD",		".")
	COMMA		= TokenType.new(TokenCategory::OPERATOR, "COMMA",		",")
	
	# Literals #
	STRING  	= TokenType.new(TokenCategory::LITERAL, "STRING")
	NUMBER		= TokenType.new(TokenCategory::LITERAL	, "NUMBER")
	
end

# ----------- #
# class Token #
# --------------------------------------- #
# Contains the data for a singular token. #
# --------------------------------------- #
class Token
	attr_accessor :type
	attr_accessor :data
	attr_accessor :column
	attr_accessor :line
	
	def initialize(type, data, column, line)
		@type = type
		@data = data
		@column = column
		@line = line
	end
end


# --------------- #
# class Tokenizer #
# ------------------------------------------------------------- #
# This is where all the magic happens.  The tokenizer tokenizes #
# the data and turns it into tokens.  Each token containing		#
# many details about its origin in the original code.           #
# All by passing it .tokenize("code")							#
# ------------------------------------------------------------- #
class Tokenizer
	
	def initialize(code)
		# Class scoped variable design.
		@code = code
		@line = 0
		@column = 0
		@index = 0
		@lastLineSize = 0
	end
	
	# Function to return an array of tokens from the code given to the class on intialization.
	def tokenize
		# Array to contain all tokens.
		tokenArray = []
		# While getChar returns anything other than ""
		while getChar
			# Loop to next character until not a space.
			while charIsWhitespace
				nextChar
			end
			# Breaks if it hits the dreaded empty string.
			if getChar == ""
				break
			end
			# If character is a letter.
			if(charIsAlpha) 
				# Initialize local variables for scope.
				m = ""
				line = @line
				column = @column			
				# While character is letter or number or underscore,
				#  add to string "m" current character.
				while(charIsAlpha or charIsDigit or getChar == '_')
					m += getChar
					nextChar
				end
				# If the keywords include "m" string in hash array,
				#	add to tokenArray a new token with the keywords having "m" as an index key,
				#	its column and line as well for future use and debugging.
				if(Tokens::KEYWORDS.include?(m))
					tokenArray.push Token.new(Tokens::KEYWORDS[m], m, column, line)
				# Must be identifier, add to array as identifier.
				else
					tokenArray.push Token.new(Tokens::IDENT, m, column, line)
				end
			# If the current character is a number.
			elsif(charIsDigit)
				# Initialize local variables for scope.
				m = ""
				line = @line
				column = @column
				# Bool is for exception checking on periods.  Most likely will be removed,
				# have yet to decide on ranges.
				dot = false
				# While char is number or period,
				while(charIsDigit or getChar == '.')
					# if period
					if(getChar == '.')
						# if dot is true
						if(dot)
							# Create exception class message.
							TokenizerException.new(column, line, "Number literal contains too many dots.")
						end
						# Sets flag for second dot if it happens before leaving scope.
						dot = true
					end
					# String adds new character and increments
					m += getChar
					nextChar
				end
				# Token complete, push token as number into tokenArray
				tokenArray.push Token.new(Tokens::NUMBER, m, column, line)
			# Current character doesn't fit into letter or number parameters.
			else
				# More instance variables
				column = @column
				line = @line
				# Starts off by saying this is a character, then moving to the next to check.
				m = getChar
				nextChar
				# While the string is in the operators add and increment character.
				while(Tokens::OPERATORS.include?(m))
					m += getChar
					nextChar
				end
				# Jump back to the last character
				prevChar()
				# Flip the characters.
				m = m.slice(0, m.size - 1)
				# Pushes another token into the array.
				tokenArray.push Token.new(Tokens::OPERATORS[m], m, column, line)
			end
		end
		return tokenArray
	end
	
	# Gets the current character in the code, unless nil.
	def getChar
		if @index <= @code.size - 1
			return @code[@index] if !@code[@index].nil?
		end
		# If nil return empty string.
		return ""
	end
	
	# Subtracts one character position.
	def prevChar
		if getChar == '\n'
			@line -= 1
			@column = @lastLineSize
		end
		@index -= 1
		@column -= 1
	end
	
	# Adds one character position.
	def nextChar
		if getChar == "\n"
			@line += 1
			@column = @lastLineSize
		end
		@index += 1
		@column += 1
	end
	
	# Is character a space?
	def charIsWhitespace
		c = getChar
		return (c == " " or c == "\t" or c == "\r" or c == "\n")
	end
	
	# Is character a letter?
	def charIsAlpha
		c = getChar
		return ((c >= 'A') && (c <= 'Z')) || ((c >= 'a') && (c <= 'z'))
	end
	
	# Is character a number?
	def charIsDigit
		c = getChar
		return (c >= '0' and c <= '9')
	end
	
end