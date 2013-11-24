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
        [   # Term operators.
            Tokens::PLUS,
            Tokens::MINUS,
        ],
        [   # Factor operators.
            Tokens::MULT,
            Tokens::DIV,
        ],
        [   # Left terminal unary operators.
            Tokens::NOT,
        ],
        [   # Right terminal unary operators.
            # TODO
        ],
        [   # Non-terminal unary operators.
            Tokens::LPAREN,
            Tokens::LBRACKET,
        ],
        [   # Object entry operators.
            Tokens::PERIOD,
        ],
    ]

    NAMES = [
        "EXPRESSION",
        "ADDITION",
        "MULTIPLICATION",
        "LEFT_TERMINAL_UNARY",
        "RIGHT_TERMINAL_UNARY",
        "NONTERMINAL_UNARY",
        "OBJECT_ENTRY",
    ]

    EXPRESSION = 0
    ADDITION = 1
    MULTIPLICATION = 2
    LEFT_TERMINAL_UNARY = 3
    RIGHT_TERMINAL_UNARY = 4
    NONTERMINAL_UNARY = 5
    OBJECT_ENTRY = 6
end

class AtomicType
    NAMES = [
        "NUMBER",
        "STRING",
        "IDENT",
    ]

    NUMBER = 1
    STRING = 2
    IDENT = 3
end

class SyntaxTree
    def initialize(*accessors)
        @accessors = accessors
    end

    def to_s(depth = 0)
        s = "#{" " * depth}#{self.class} {\n"
        for acc in @accessors
            child = self.send(acc)
            if child.is_a?(SyntaxTree)
                s << "#{" " * (depth + 1)}#{acc}:\n#{child.to_s(depth + 1)}"
            elsif acc == :operators
                if not (self.is_a?(UnaryExpressionT) and self.type == ExpressionType::NONTERMINAL_UNARY)
                    s << "#{" " * (depth + 1)}operators: #{child.map { |token| token.match }}\n"
                else
                    s << "#{" " * (depth + 1)}operators:\n"
                    for tuple in operators
                        s << "#{tuple.to_s(depth + 2)}"
                    end
                    s << "#{" " * (depth + 1)}}\n"
                end
            elsif acc == :type
                if self.is_a? ExpressionT
                    s << "#{" " * (depth + 1)}type: #{ExpressionType::NAMES[child]}\n"
                elsif self.is_a? TupleUnaryOperator
                    s << "#{" " * (depth + 1)}type: #{TupleType::NAMES[child]}\n"
                elsif self.is_a? FactorT
                    s << "#{" " * (depth + 1)}type: #{FactorType::NAMES[child]}\n"
                end
            elsif child.is_a?(Array)
                s << "#{" " * (depth + 1)}#{acc}: {\n"
                for o in child
                    if o.is_a?(SyntaxTree)
                        s << "#{o.to_s(depth + 2)}"
                    else
                        s << "#{" " * (depth + 2)}#{o}\n"
                    end
                end
                s << "#{" " * (depth + 1)}}\n"
            else
                s << "#{" " * (depth + 1)}#{acc}: #{child}\n"
            end
        end
        return s + "#{" " * depth}}\n"
    end
end

class ProgramT < SyntaxTree
    attr_accessor :statements
    def initialize
        super(:statements)
        @statements = []
    end
end

class StatementT < SyntaxTree
end

class AssignmentT < StatementT
    attr_accessor :left
    attr_accessor :right

    def initialize
        super(:left, :right)
    end
end

class VarDeclarationT < SyntaxTree
    attr_accessor :typeExpression
    attr_accessor :ident
    attr_accessor :right

    def initialize
        super(:typeExpression, :ident, :right)
    end
end

class ExpressionT < SyntaxTree
    attr_accessor :type
    
    def initialize(type, *accessors)
        super(*accessors)
        @type = type
    end
end

class MultiExpressionT < ExpressionT
    attr_accessor :operators
    attr_accessor :expressions
    
    def initialize(type)
        super(type, :type, :operators, :expressions)
        @operators = []
        @expressions = []
    end
end

class UnaryExpressionT < ExpressionT
    attr_accessor :operators
    attr_accessor :expression
    
    def initialize(type)
        super(type, :type, :operators, :expression)
        @operators = []
    end
end

class FactorType
    STRING = 0
    NUMBER = 1
    IDENT = 2
    PAREN = 3

    NAMES = [
        "STRING",
        "NUMBER",
        "IDENT",
        "PAREN",
    ]
end

class FactorT < SyntaxTree
    attr_accessor :type

    def initialize(type, *accessors)
        super(*accessors)
        @type = type
    end
end

class AtomicFactorT < FactorT
    TYPES = {
        Tokens::STRING => FactorType::STRING,
        Tokens::NUMBER => FactorType::NUMBER,
        Tokens::IDENT => FactorType::IDENT,
    }

    attr_accessor :data

    def initialize(type, data)
        super(TYPES[type], :data)
        @data = data
    end
end

class ParenFactorT < FactorT
    attr_accessor :expression

    def initialize
        super(FactorType::PAREN, :expression)
    end
end

class TupleType
    NAMES = [
        "CALL",
        "INDEX",
    ]

    CALL = 0
    INDEX = 1
end

class TupleUnaryOperator < SyntaxTree
    attr_accessor :type
    attr_accessor :tuple

    def initialize(type, tuple)
        super(:type, :tuple)
        @type = type
        @tuple = tuple
    end
end