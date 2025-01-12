package org.big.erd.ide.commands

import org.eclipse.xtext.ide.server.commands.IExecutableCommandService
import org.eclipse.lsp4j.ExecuteCommandParams
import org.eclipse.xtext.ide.server.ILanguageServerAccess
import org.eclipse.xtext.util.CancelIndicator
import org.big.erd.util.ErUtils
import com.google.gson.JsonPrimitive
import org.eclipse.xtext.generator.GeneratorContext
import com.google.inject.Inject
import java.util.HashMap
import java.util.Map
import org.big.erd.generator.IErGenerator
import org.big.erd.generator.SqlGenerator
import org.eclipse.xtext.validation.IResourceValidator
import org.eclipse.xtext.validation.CheckMode

class ErCommandService implements IExecutableCommandService {
	
	@Inject IResourceValidator resourceValidator
	
	Map<String, IErGenerator> generators
	static final String GENERATE_PREFIX = "erdiagram.generate"
	static final String GENERATE_SQL_COMMAND = GENERATE_PREFIX + ".sql"
	
	
	override initialize() {
		generators = new HashMap
		generators.put(GENERATE_SQL_COMMAND, new SqlGenerator)
		return #[ 
			GENERATE_SQL_COMMAND
		]
	}
	
	override execute(ExecuteCommandParams params, ILanguageServerAccess access, CancelIndicator cancelIndicator) {
		if (params.command.startsWith(GENERATE_PREFIX)) {
			val fsa = ErUtils.getJavaIoFileSystemAccess()
			fsa.setOutputPath("generated")
			val uri = params.arguments.head as JsonPrimitive
			
			if (uri !== null) {
				if (!generators.containsKey(params.command)) {
					return "Error! Unknown generator for command '" + params.command + "'"
				}
				val generator = generators.get(params.command)
				
				return access.doRead(uri.asString) [
						try {
							// check for syntax errors
							val errors = resource.getErrors();
							if (!errors.isEmpty) {
								return "Error! Model contains syntax errors."
							}
							
							// check for validation errors
							val issues = resourceValidator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl);
							if (!issues.isEmpty) {
								return "Error! Model contains validation errors."
							}
							
							// execute the generator
							generator.generate(resource, fsa, new GeneratorContext())
							return "Successfully generated code!"
						} catch (Exception ex) {
							return "Error! Exception while executing generator: \n" + ex.message
						}
					].get
			} else {
				return "Error! Missing resource URI"
			}
		}
		
		return "Error! Unknown Command"
	}
}