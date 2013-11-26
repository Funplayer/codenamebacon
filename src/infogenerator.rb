class StructureException < Exception
    def initialize(got, expected)
        super("Expected #{expected.name} at line #{(got.line + 1)}, column #{(got.column + 1)}. Got #{got.type.name}.")
    end
end

class CompileType
end

class CompileMethod
    attr_accessor :returnType
    attr_accessor :paramTypes
end

class ClassType < CompileType
    attr_accessor :orderedMembers
    attr_accessor :methods
end

class PrimitiveType < CompileType
    attr_accessor :bits
    attr_accessor :signed
    attr_accessor :floatingPoint

    def initialize(bits, signed, floatingPoint)
        @bits = bits
        @signed = signed
        @floatingPoint = floatingPoint
    end

    BYTE =    PrimitiveType.new(8,  true,  false)
    UBYTE =   PrimitiveType.new(8,  false, false)
    SHORT =   PrimitiveType.new(16, true,  false)
    USHORT =  PrimitiveType.new(16, false, false)
    INT =     PrimitiveType.new(32, true,  false)
    UINT =    PrimitiveType.new(32, false, false)
    LONG =    PrimitiveType.new(64, true,  false)
    ULONG =   PrimitiveType.new(64, false, false)
    FLOAT =   PrimitiveType.new(32, false, true)
    UFLOAT =  PrimitiveType.new(32, false, true)
    DOUBLE =  PrimitiveType.new(64, false, true)
    UDOUBLE = PrimitiveType.new(64, false, true)
end

class TypeIdentPair
    attr_accessor :type
    attr_accessor :ident
end

class Scope
    attr_accessor :locals
end

class InfoCodeBlock
	attr_accessor :data
	attr_accessor :layer
	attr_accessor :type
	def initialize(*params)
		@type = params[0]
		@layer = params[1]
		@data = []
		for i in 2...params.size
			@data.push params[i]
		end 
		return @data
	end
end

class InfoGenerator
	attr_accessor :blockHandle
	# Layer 0 is the class layer, and all things stored outside the classes.  #
	# Layer 1 is the function layer, and all things stored outside functions. #
	# Layer 2

    def initialize(programTree, bits)
        @layer = 0
        @program = programTree
        @bits = bits
        @blockHandle = {}
        # On initialize, setup the layers and top level.
        genStartup
        # Continue with genCode to loop until finished.
        genCurrentLayer
    end

    # Runs the startup procedure for the code block #
    def genStartup
    	newLayer
    	for statement in @program.statements
            case statement
            when ClassDeclarationT
            	genClass(statement)
            when FunctionDeclarationT
            	genFunction(statement)
            when VarDeclarationT
            	genVarDeclaration(statement)
            when ConstructorDeclarationT
            	genConstructor(statement)
            when CallT
            	genCall(statement)
            when ReturnT
            	genReturn(statement)
            when AssignmentT
            	genAssignment(statement)
            when BranchT
            	genBranch(statement)
            when ExpressionT
            	genExpression(statement)
            else
            	StructureException.new(statement,"ParsedTree")
            end
        end
        nextLayer
    end

    # Generates each subsequent layer.
    def genCurrentLayer
    end

    def genConstructor(statement)
    	pushToLayer(InfoCodeBlock.new('constructor',@layer,statement.paramTypes, statement.paramNames, statement.block))
    end
	def genBranch(statement)
		pushToLayer(InfoCodeBlock.new('branch',@layer,statement.ifCond, statement.ifBlock, 
            		statement.elseifConds, statement.elseifBlocks,statement.elseBlock))
	end
    def genCall(statement)
    	pushToLayer(InfoCodeBlock.new('call',@layer,statement.expression))
    end
    def genReturn(statement)
    	pushToLayer(InfoCodeBlock.new('return',@layer,statement.expression))
    end
    def genExpression(statement)
    	pushToLayer(InfoCodeBlock.new('expression',@layer,statement.type))
    end
    def genClass(statement)
    	pushToLayer(InfoCodeBlock.new('class',@layer,statement.name, statement.typeParameters, 
    		statement.extendType, statement.implementTypes, statement.block))
    end
    def genFunction(statement)
    	pushToLayer(InfoCodeBlock.new('function',@layer,statement.returnType, statement.name, 
    		statement.paramTypes,statement.paramNames, statement.block))
    end
    def genAssignment(statement)
        pushToLayer(InfoCodeBlock.new('assignment',@layer,statement.left,statement.right))
    end
    def genVarDeclaration(statement)
    	pushToLayer(InfoCodeBlock.new('declaration',@layer,statement.type,statement.name,
            	statement.right))
    end

    # Layer handles
    def pushToLayer(info)
    	@blockHandle[@layer].push(info)
    end
    def newLayer
    	@blockHandle[@layer] = []
    end
    def removeLayer(layer)
    	@blockHandle.delete(layer)
    end
    def nextLayer
    	@layer += 1
    end
    def prevLayer
    	@layer -= 1
    end
    def jumpToLayer(layer)
    	@layer = layer
    end
end

=begin
    def allocReg
        case @bits
        when 16
            registers[RawAssembly::REGISTERS16[@registers.size]] = true
        when 32
            registers[RawAssembly::REGISTERS32[@registers.size]] = true
        when 64
            registers[RawAssembly::REGISTERS64[@registers.size]] = true
        end
    end

    def freeReg(reg)
        registers.delete(reg)
    end

    def emit(str)
        @output << "#{str}\n"
    end
=end