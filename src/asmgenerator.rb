class AsmGenerator

	def initialize(programTree)
		@program = programTree
	end

	def genProgram
		for statement in @program.statements
			case statement.class
			when AssignmentT
				genAssignment(statement)
			when VarDeclarationT
				genDeclaration(statement)
			end
		end
		return
	end

	def genAssignment(statement)
		
	end

	def genDeclaration(statement)

	end
	
	def genProcedure

	end

	def objectType

	end

end