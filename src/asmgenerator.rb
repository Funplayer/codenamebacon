require "assembly.rb"

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

class AsmGenerator

    def initialize(programTree, bits)
        @output = ""
        @program = programTree
        @bits = bits
        @registers = { }
    end

    def genBlock
        
        
        block = []
        for statement in @program.statements
            case statement
            when AssignmentT
                genAssignment(statement)
            when VarDeclarationT

            when BranchT

            end
        end
        return
    end

    def genAssignment(statement)
        return "stuffs"
    end

    def genDeclaration(statement)

    end

    def genProcedure

    end

    def objectType

    end

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

end