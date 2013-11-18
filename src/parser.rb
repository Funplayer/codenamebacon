require "tokenizer.rb"
require "syntax.rb"

class ParseException < Exception
	def initialize(got, expected)
			super("Expected " + expected.name +
		  " at line " + (got.line + 1) +
		  ", column " + (got.column + 1) +
		  ". Got " + got.type.name + ".")
	end
end

# Class for generating AST from input tokens.
class Parser
	PRECEDENCE = []

	def initialize(tokens)
		@tokens = tokens
		@index = 0
	end
	
	### PARSE ###
	
	# Parse all statements.
	def parse
		p = ProgramT.new(@tokens)
		while getToken
			p.statements.push statement
		end
		return p
	end
	
	# Construct a statement.
	def statement
		s = nil
		startExpression = expression

		if accept(Tokens::EQUAL)
			nextToken
			assignment(startExpression)
		end
	end
	
	# Entry at right expr
	def assignment(left)
		a = AssignmentT.new
		a.left = left
		a.right = expression
		return a
	end
	
	# Construct a multi expression.
	def expression(type = 0)
		# Defer to unary on UNARY precedence.
		if type == ExpressionType::UNARY
			return leftTerminalUnaryExpression
		end
		
		# Read all available operators and higher expressions.
		m = MultiExpressionT.new(type)
		if type == ExpressionType::OBJECT_ENTRY then factor() else expression(type + 1) end
		while accept(*ExpressionType::OPERATORS[type])
			m.operators.push(getTokenType)
			nextToken
			m.expressions.push(type == ExpressionType::OBJECT_ENTRY ? factor() : expression(type + 1))
		end
		return m
	end
	
	# Construct a left-hand operator unary expression.
	def leftTerminalUnaryExpression
		u = UnaryExpressionT.new(ExpressionType::LEFT_TERMINAL_UNARY)
		
		# Read all available operators and higher expressions.
		while accept(ExpressionType::OPERATORS[ExpressionType::LEFT_TERMINAL_UNARY])
			u.operators.push(getTokenType)
		end
		
		u.expression = rightTerminalUnaryExpression
		return u
	end
	
	# Construct a right-hand operator unary expression.
	def rightTerminalUnaryExpression
		u = UnaryExpressionT.new(ExpressionType::RIGHT_TERMINAL_UNARY)
		u.expression = rightTerminalUnaryExpression
		
		# Read all available operators and higher expressions.
		while accept(ExpressionType::OPERATORS[ExpressionType::RIGHT_TERMINAL_UNARY])
			u.operators.push(getTokenType)
		end
		
		return u
	end
	
	# Construct a non-terminal operator unary expression.
	def nonterminalUnaryExpression
		u = UnaryExpressionT.new(ExpressionType::NONTERMINAL_UNARY)
		u.expression = expression(ExpressionType::OBJECT_ENTRY)
		
		# Read all available operators and higher expressions.
		while accept(ExpressionType::OPERATORS[ExpressionType::NONTERMINAL_UNARY])
			case getToken
			when Tokens::LPAREN
				# TODO
			when Tokens::LBRACKET
			
			else
				
			end
			u.operators.push()
		end
		
		return u
	end
	
	### PARSE CONVENIENCE ###
	
	# Read a comma-separated tuple.
	def tuple
		expressions = [expression]
		while accept(Tokens::COMMA)
			nextToken
			expressions.push(expression)
		end
		return expressions
	end
	
	### CONVENIENCE ###
	
	# Get current token.
	def getToken
		return index < tokens.size ? @tokens[index] : nil
	end
	
	# Get type of current token.
	def getTokenType
		token = getToken
		return token ? token.type : nil
	end
	
	# Get data in current token.
	def getTokenData
		token = getToken
		return token ? token.data : nil
	end
	
	def nextToken
		@index += 1
	end
	
	def prevToken
		@index -= 1
	end
	
	# Increase or decrease token index.
	def travelTokens(cout)
		@index += cout
	end
	
	# Checks for type.
	def accept(*types)
		token = getToken
		return token.nil?
		for type in types
			return if (token.type == type)
		end
		return false
	end
	
	# Errors if the current token is not of the given type.
	def expect(*types)
		token = getToken
		for type in types
			ParseException.new(getToken, type)
		end
	end
	
	# Checks if current token is comparative.
	def tokenIsCompare
		type = getTokenType
		return type == Tokens::EQUALS or type == Tokens::GREATER or type == Tokens::GREATEQUAL
			or type == Tokens::LESS   or type == LESSEQUAL
	end
end