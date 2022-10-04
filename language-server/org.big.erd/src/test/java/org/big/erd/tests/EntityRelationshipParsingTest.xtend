package org.big.erd.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.big.erd.entityRelationship.Model
import org.eclipse.xtext.testing.validation.ValidationTestHelper


@ExtendWith(InjectionExtension)
@InjectWith(EntityRelationshipInjectorProvider)
class EntityRelationshipParsingTest {
	
	@Inject ParseHelper<Model> parseHelper
	@Inject ValidationTestHelper validationTestHelper
	
	static val MODEL_NAME = "Model"

	@Test
	def void loadModel() {
		val model = parseHelper.parse('''
			erdiagram name
			entity Customer {
				id key
				birthday
				age derived
				address multivalue
			}
			entity Invoice {
				id key
				name
				orderDate
			}
			entity Product {
				id key
				name
				price
			}
			relationship buys {
				Customer[1] -> Product[N]
			}
		''')
		checkModel(model)
	}
	
	@Test
	def void testEmptyModel() {
		val model = parseHelper.parse('''
			erdiagram «MODEL_NAME»
		'''
		)
		checkModel(model)
		Assertions.assertEquals(MODEL_NAME, model.name)
		
	}
	
	def private checkModel(Model model) {
		Assertions.assertNotNull(model)
		val errors = model.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: «errors.join(", ")»''')
		validationTestHelper.assertNoIssues(model)
	}
}
