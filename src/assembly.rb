# Overall data structure for the class virtualization #
class AsmClass
	attr_accessor :name
	attr_accessor :stack
	attr_accessor :bitCount
	attr_accessor :directives
	attr_accessor :procedures
	def initialize(name,bitCount = 32)
		# Should help with label encapsulation.
		@name = name
		@directives = []
		@procedures = []
	end
end

# Singular static directive, a few are required #
class AsmStaticDirective
	attr_accessor :type
	def initialize(type)
		@type = type
	end
end

# A singular register 
class AsmRegister
	attr_accessor :type
	attr_accessor :bits
	def initialize(type, bits)
		# Stores the registry type as a string
		#  with a bit value.
		@type = type
		@bits = bits
	end
end
# --------------------------------------------------------------- #
class AsmMnemonic
	attr_accessor :type
	def initialize(type)
		# Holds Mnemonic type for comparison with
		# the mnemonic structure table.
		@type = type
	end
end

# Static data type for the all fields.
class AsmDataType < AsmClass
	attr_accessor :bits
	attr_accessor :type
	attr_accessor :name
	def initialize(name, type, bits)
		@name = name
		@type = type
		@bits = bits
	end
end

class AsmProcedure < AsmClass
	attr_accessor :name
	attr_accessor :open
	attr_accessor :close
	attr_accessor :instructions
	def initialize(name = "main")
		# Procedure name for instruction encapsulation.
		@name = name
		@open = RawAssembly::PROC
		@close = RawAssembly::ENDP
		@instructions = []
	end
end

class AsmInstruction < AsmProcedure
	attr_accessor :label
	attr_accessor :mnemonic
	attr_accessor :params
	def initialize(label = "")
		# Instruction label for logical jumping.
		@label = label
	end
end

# --------------------------------------------------------------- #
# Data stored in memory, the :left expression post data
# .DATA
# memID TYPE val
class DataMemory
	attr_accessor :type
	def initialize(type, use)

	end
end

# Data required as a suppliment for an arithmetic expression
# registerType
class DataRegister
	attr_accessor :type
	def initialize(type, use)

	end
end

# Data declared in statement with a type, such as 5, 7, "bacon"
class DataImmediate
	attr_accessor :type
	attr_accessor :val
	def initialize(type = "", val = "")

	end
end

class RawAssembly
	# 80x86 Architecture #
	
	# ---------- #
	# Directives #
	MODEL_FLAT_ = AsmStaticDirective.new('.MODEL FLAT')
	BIT32_ = AsmStaticDirective.new('.586')
	BIT64_ = AsmStaticDirective.new('')
	STACK_ = AsmStaticDirective.new('.STACK 4096')
	DATA_ = AsmStaticDirective.new('.DATA')
	CODE_ = AsmStaticDirective.new('.CODE')
	PROC_ = AsmStaticDirective.new('PROC')
	ENDP_ = AsmStaticDirective.new('ENDP')
	
	# ---------- #
	# Data Types #
	## ----------- ##
	## 32 Bit Mode ##
	BYTE = AsmDataType.new('BYTE', 'signed', 8)
	WORD = AsmDataType.new('WORD', 'signed', 16)
	DWORD = AsmDataType.new('DWORD', 'signed', 32)
	## ----------- ##
	## 64 Bit Mode ##
	QWORD = AsmDataType.new('QWORD', 'signed', 64)
	
	# --------- #
	# Registers #
	## ----------- ##
	## 32 Bit Mode ##
	# 16 bit
	AX = AsmRegister.new('ax', 16)
	BX = AsmRegister.new('bx', 16)
	CX = AsmRegister.new('cx', 16)
	DX = AsmRegister.new('dx', 16)
	SP = AsmRegister.new('sp', 16)
	BP = AsmRegister.new('bp', 16)
	SI = AsmRegister.new('si', 16)
	DI = AsmRegister.new('di', 16)
	# 32 bit
	EAX = AsmRegister.new('eax', 32)
	EBX = AsmRegister.new('ebx', 32)
	ECX = AsmRegister.new('ecx', 32)
	EDX = AsmRegister.new('edx', 32)
	ESP = AsmRegister.new('esp', 32)
	EBP = AsmRegister.new('ebp', 32)
	ESI = AsmRegister.new('esi', 32)
	EDI = AsmRegister.new('edi', 32)
	## ----------- ##
	## 64 bit Mode ##
	RAX = AsmRegister.new('rax', 64)
	RBX = AsmRegister.new('rbx', 64)
	RCX = AsmRegister.new('rcx', 64)
	RDX = AsmRegister.new('rdx', 64)
	RSP = AsmRegister.new('rsp', 64)
	RBP = AsmRegister.new('rbp', 64)
	RSI = AsmRegister.new('rsi', 64)
	RDI = AsmRegister.new('rdi', 64)

	## Ordered registers ##
	REGISTERS16 = [
		AX,
		BX,
		CX,
		DX,
		SP,
		BP,
		SI,
		DI,
	]

	REGISTERS32 = [
		EAX,
		EBX,
		ECX,
		EDX,
		ESP,
		EBP,
		ESI,
		EDI,
	]

	REGISTERS64 = [
		RAX,
		RBX,
		RCX,
		RDX,
		RSP,
		RBP,
		RSI,
		RDI,
	]
	
	# -------------- #
	# Mnemonic Types #
	BIT32 = {
		'mov'  => AsmMnemonic.new('mov'),#,['I','R','M'],['I','R','M']),
		'xchg' => AsmMnemonic.new('xchg'),
		'add'  => AsmMnemonic.new('add'),
		'sub'  => AsmMnemonic.new('sub'),
		'mul'  => AsmMnemonic.new('mul'),
		'imul' => AsmMnemonic.new('imul'),
		'div'  => AsmMnemonic.new('div'),
		'idiv' => AsmMnemonic.new('idiv'),
	}
	
end