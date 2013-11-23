require "tokenizer.rb"
require "syntax.rb"

class ParseException < Exception
    def initialize(got, expected)
            super("Expected #{expected.name} at line #{(got.line + 1)}, column #{(got.column + 1)}. Got #{got.type.name}.")
    end
end

# Class for generating AST from input tokens.
class Parser
    def initialize(tokens)
        @tokens = tokens
        @index = 0
    end
    
    # PARSE
    #
    # Parse methods should always begin at start of construct and end one token after construct. Should be
    # documented at method if this is not the case.
    #
    
    # Parse all statements.
    def parse
        p = ProgramT.new()
        while getToken
            p.statements.push(statement())
        end
        return p
    end
    
    # Construct a statement.
    def statement
        s = nil
        startExpression = expression()

        if accept(Tokens::EQUAL)
            nextToken()
            s = assignment(startExpression)
        end

        return s
    end
    
    # Construct an assignment statement.
    # Entry at right expression.
    def assignment(left)
        a = AssignmentT.new()
        a.left = left
        a.right = expression()
        return a
    end
    
    # Construct a multi expression.
    def expression(type = 0)
        # Defer to unary on UNARY precedence.
        if type == ExpressionType::LEFT_TERMINAL_UNARY
            return leftTerminalUnaryExpression()
        end
        
        # Read all available operators and higher expressions.
        m = MultiExpressionT.new(type)
        m.expressions.push(type == ExpressionType::OBJECT_ENTRY ? factor() : expression(type + 1))
        while accept(*ExpressionType::OPERATORS[type])
            m.operators.push(getTokenType)
            nextToken()

            # Parse the next expression or go to factor.
            m.expressions.push(type == ExpressionType::OBJECT_ENTRY ? factor() : expression(type + 1))
        end
        return m
    end
    
    # Construct a left-hand operator unary expression.
    def leftTerminalUnaryExpression
        u = UnaryExpressionT.new(ExpressionType::LEFT_TERMINAL_UNARY)
        
        # Read all available operators and higher expressions.
        while accept(*ExpressionType::OPERATORS[ExpressionType::LEFT_TERMINAL_UNARY])
            u.operators.push(getTokenType)
            nextToken()
        end
        
        u.expression = rightTerminalUnaryExpression()
        return u
    end
    
    # Construct a right-hand operator unary expression.
    def rightTerminalUnaryExpression
        u = UnaryExpressionT.new(ExpressionType::RIGHT_TERMINAL_UNARY)
        u.expression = nonterminalUnaryExpression()
        
        # Read all available operators and higher expressions.
        while accept(*ExpressionType::OPERATORS[ExpressionType::RIGHT_TERMINAL_UNARY])
            u.operators.push(getTokenType)
        end
        
        return u
    end
    
    # Construct a non-terminal operator unary expression.
    def nonterminalUnaryExpression
        u = UnaryExpressionT.new(ExpressionType::NONTERMINAL_UNARY)
        u.expression = expression(ExpressionType::OBJECT_ENTRY)

        # Read all available operators and higher expressions.
        while accept(*ExpressionType::OPERATORS[ExpressionType::NONTERMINAL_UNARY])
            case getTokenType()
            when Tokens::LPAREN
                u.operators.push(TupleUnaryOperator.new(TupleType::CALL, tuple(Tokens::LPAREN, Tokens::RPAREN)))
            when Tokens::LBRACKET
                u.operators.push(TupleUnaryOperator.new(TupleType::INDEX, tuple(Tokens::LBRACKET, Tokens::RBRACKET)))
            else
                # TODO: Throw error or delete this block.
            end
        end
        
        return u
    end
    
    # Read a factor.
    def factor
        f = nil

        case getTokenType()
        when Tokens::LPAREN
            nextToken()
            f = ParenFactorT.new()
            f.expression = expression()
        else
            if !AtomicFactorT::TYPES.include?(getTokenType())
                throw ParseException.new(getToken(), Tokens::STRING)
            end
            f = AtomicFactorT.new(getTokenType(), getTokenData())
        end

        nextToken()
        return f
    end

    # Read a comma-separated tuple.
    def tuple(left, right)
        expect(left)
        nextToken()
        expressions = [expression()]
        while accept(Tokens::COMMA)
            nextToken()
            expressions.push(expression())
        end
        expect(right)
        nextToken()
        return expressions
    end
    
    # CONVENIENCE
    #
    # Convenience functions for parser.
    #
    
    # Get current token.
    def getToken
        return @tokens[@index]
    end
    
    # Get type of current token.
    def getTokenType
        token = getToken()
        return token ? token.type : nil
    end
    
    # Get data in current token.
    def getTokenData
        token = getToken()
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
        token = getToken()
        return false if token.nil?
        for type in types
            return true if token.type == type
        end
        return false
    end
    
    # Errors if the current token is not of the given type.
    def expect(*types)
        token = getToken()
        for type in types
            ParseException.new(token, type)
        end
    end
end