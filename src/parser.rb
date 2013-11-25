require "tokenizer.rb"
require "syntax.rb"

class ParseException < Exception
    def initialize(got, expected)
        if expected.is_a? TokenType
            super("Expected #{expected.name} at line #{(got.line + 1)}, column #{(got.column + 1)}. Got #{got.type.name}.")
        elsif expected.is_a? String
            super("Error at line #{(got.line + 1)}, column #{(got.column + 1)}. #{expected} Got #{got.type.name}.")
        end
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
        p = BlockT.new()
        while getToken
            p.statements.push(statement())
        end
        return p
    end
    
    # Construct a statement.
    def statement(isClassContext = false)
        case getTokenType()
        when Tokens::IF
            return branch()
        when Tokens::DO
            return functionDeclaration
        when Tokens::SELF
            if isClassContext
                return constructorDeclaration
            end
            return statementWithExpression
        when Tokens::RETURN
            r = ReturnT.new
            nextToken
            if accept(Tokens::END_)
                return r
            end
            r.expression = expression
            return r
        when Tokens::CLASS
            return classDeclaration
        else
            return statementWithExpression
        end

        throw ParseException.new(getToken(), "Cannot read next statement.")
    end

    def statementWithExpression
        startExpression = expression()

        if accept(Tokens::EQUAL)
            nextToken()
            return assignment(startExpression)
        elsif accept(Tokens::IDENT)
            return varDeclaration(startExpression)
        else
            # TODO: Throw error if expression is not a call.
            c = CallT.new()
            c.expression = startExpression
            return c
        end
    end
    
    # Construct an assignment statement.
    # Entry at right expression.
    def assignment(left)
        a = AssignmentT.new()
        a.left = left
        a.right = expression()
        return a
    end

    # Construct a variable declaration with an optional assignment.
    # Entry at variable name identifier.
    def varDeclaration(typeExpression)
        d = VarDeclarationT.new()
        d.typeExpression = typeExpression
        expect(Tokens::IDENT)
        d.name = getTokenData()
        nextToken()
        if accept(Tokens::EQUAL)
            nextToken()
            d.right = expression()
        end
        return d
    end

    # Construct a branch statement.
    def branch
        b = BranchT.new()
        expect(Tokens::IF)
        nextToken()
        b.ifCond = expression()
        expect(Tokens::THEN)
        nextToken()
        b.ifBlock = block(false, Tokens::ELSEIF, Tokens::ELSE, Tokens::END_)

        while accept(Tokens::ELSEIF)
            nextToken()
            b.elseifConds.push(expression())
            expect(Tokens::THEN)
            nextToken()
            b.elseifBlocks.push(block(false, Tokens::ELSEIF, Tokens::ELSE, Tokens::END_))
        end

        if accept(Tokens::ELSE)
            nextToken()
            b.elseBlock = block(false, Tokens::ELSEIF, Tokens::ELSE, Tokens::END_)
        end

        nextToken()
        return b
    end

    # Construct a function declaration.
    def functionDeclaration
        f = FunctionDeclarationT.new

        expect(Tokens::DO)
        nextToken
        f.returnType = expression
        f.name = getTokenData
        nextToken
        parameters(Tokens::LPAREN, Tokens::RPAREN, f.paramTypes, f.paramNames)
        f.block = block(false, Tokens::END_)
        nextToken

        return f
    end

    # Construct a constructor declaration.
    def constructorDeclaration
        c = ConstructorDeclarationT.new

        expect(Tokens::SELF)
        nextToken
        parameters(Tokens::LPAREN, Tokens::RPAREN, c.paramTypes, c.paramNames)
        puts("#{getToken.inspect}")
        c.block = block(false, Tokens::END_)
        nextToken

        return c
    end

    # Construct a class declaration.
    def classDeclaration
        c = ClassDeclarationT.new
        expect(Tokens::CLASS)
        nextToken
        expect(Tokens::IDENT)
        c.name = getTokenData
        nextToken

        if accept(Tokens::LPAREN)
            nextToken
            c.typeParameters.push(getTokenData)
            nextToken
            while accept(Tokens::COMMA)
                nextToken
                c.typeParameters = tuple(Tokens::LPAREN, Tokens::RPAREN)
                nextToken
            end
            expect(Tokens::RPAREN)
            nextToken
        end

        if accept(Tokens::EXTENDS)
            nextToken
            c.extendType = expression
        end

        if accept(Tokens::IMPLEMENTS)
            nextToken
            c.implementTypes.push(expression)
            while accept(Tokens::COMMA)
                nextToken
                c.implementTypes.push(expression)
            end
        end

        c.block = block(true, Tokens::END_)
        nextToken

        return c
    end

    # Construct a statement filled block.
    # Entry at first statement.
    # Returns on stop token.
    def block(isClassContext, *stop)
        b = BlockT.new()
        while !stop.include?(getTokenType())
            b.statements.push(statement(isClassContext))
        end
        return b
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
                throw ParseException.new(getToken(), "Expected a string or number.")
            end
            f = AtomicFactorT.new(getTokenType(), getTokenData())
        end

        nextToken()
        return f
    end

    # Read a comma-separated tuple.
    def tuple(left, right)
        expect(left)
        nextToken

        if accept(right)
            nextToken
            return []
        end

        expressions = [expression]

        while accept(Tokens::COMMA)
            nextToken()
            expressions.push(expression())
        end
        expect(right)
        nextToken()
        return expressions
    end

    # Read a comma-separated type tuple.
    def parameters(left, right, types, names)
        expect(left)
        nextToken()

        if accept(right)
            nextToken
            return
        end

        types.push(expression)
        names.push(getTokenData)
        nextToken
        while accept(Tokens::COMMA)
            nextToken
            types.push(expression)
            names.push(getTokenData)
            nextToken
        end
        expect(right)
        nextToken
    end

    def call?(e)
        for i in 0...ExpressionType::RIGHT_TERMINAL_UNARY
            if e.operators.size > 0
                return false
            end
            e = e.expressions[0]
        end

        
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