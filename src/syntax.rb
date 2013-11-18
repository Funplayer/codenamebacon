require "tokenizer.rb"

class ExpressionType
	OPERATORS = [
		[   # Compare operators.
			Tokens::EQUALS, 
			Tokens::INEQUAL, 
			Tokens::LESS, 
			Tokens::LESSEQUAL,
			Tokens::GREATER, 
			Tokens::GREATEQUAL, 
		],
		[	# Term operators.
			Tokens::PLUS,
			Tokens::MINUS,
		],
		[	# Factor operators.
			Tokens::MULT,
			Tokens::DIV,
		],
		[	# Left terminal unary operators.
			Tokens::NOT,
		],
		[	# Right terminal unary operators.
			# TODO
		],
		[	# Non-terminal unary operators.
			Tokens::LPAREN,
			Tokens::LBRACKET,
		],
		[	# Object entry operators.
			Tokens::PERIOD,
		],
	]

	EXPRESSION = 0
	COMPARE = 1
	TERM = 2
	FACTOR = 3
	LEFT_TERMINAL_UNARY = 4
	RIGHT_TERMINAL_UNARY = 5
	NONTERMINAL_UNARY = 6
	OBJECT_ENTRY = 7
end

class AtomicType
	NUMBER = 1
	STRING = 2
	IDENT = 3
end

class SyntaxTree
end

class ProgramT < SyntaxTree
	attr_accessor :statements
	def initialize(statements)
		@statements = statements
	end
end

class StatementT < SyntaxTree
end

class AssignmentT < StatementT
	attr_accessor :left
	attr_accessor :right
end

class ExpressionT < SyntaxTree
	attr_accessor :type
	
	def initialize(type)
		@type = type
	end
end

class MultiExpressionT < ExpressionT
	attr_accessor :operators
	attr_accessor :expressions
	
	def initialize(type)
		super(type)
		@operators = []
		@expressions = []
	end
end

class UnaryExpressionT < ExpressionT
	attr_accessor :operators
	attr_accessor :expression
	
	def initialize(type)
		super(type)
		@operators = []
	end
end

class FactorT < SyntaxTree
end

class AtomicFactorT < FactorT
	attr_accessor :type
	
	def intialize(type)
		@type = type
	end
end

class ParenFactorT < FactorT
	
end

class ArrayLiteralT < FactorT
	
end

class TupleUnaryOperator
	attr_accessor :type
	attr_accessor :tuple
end