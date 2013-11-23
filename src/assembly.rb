class RawAssembly
	# 80x86 Architecture #
	
	# ---------- #
	# Directives #
	MODEL_FLAT = AsmStaticDirective.new('.MODEL FLAT')
	BIT32 = AsmStaticDirective.new('.586')
	BIT64 = AsmStaticDirective.new('')
	STACK = AsmStaticDirective.new('.STACK 4096')
	DATA_ = AsmStaticDirective.new('.DATA')
	CODE = AsmStaticDirective.new('.CODE')
	PROC = AsmStaticDirective.new('PROC')
	ENDP = AsmStaticDirective.new('ENDP')
	
	# ---------- #
	# Data Types #
	## ----------- ##
	## 32 Bit Mode ##
	BYTE = AsmDataType.new('WORD', 'signed', 8)
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
	
	# -------------- #
	# Mnemonic Types #
	MOV = AsmMnemonic.new('mov')
	XCHG = AsmMnemonic.new('xchg')
	ADD = AsmMnemonic.new('add')
	SUB = AsmMnemonic.new('sub')
	MUL = AsmMnemonic.new('mul')
	IMUL = AsmMnemonic.new('imul')
	DIV = AsmMnemonic.new('div')
	IDIV = AsmMnemonic.new('idiv')
	
end

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

class AsmStaticDirective < AsmClass
	attr_accessor :type
	def initialize(type)
		@type = type
	end
end

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
	def intialize(name, type, bits)
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

