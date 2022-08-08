/*
 * generated by Xtext 2.24.0
 */
package org.big.erd.ide

import org.eclipse.xtext.ide.server.codeActions.ICodeActionService2
import org.eclipse.xtext.ide.server.hover.HoverService
import org.big.erd.ide.hover.ERDHoverService
import org.big.erd.ide.codeActions.ERDCodeActionService

/**
 * Editor components are registered here
 */
class EntityRelationshipIdeModule extends AbstractEntityRelationshipIdeModule {

	def Class<? extends ICodeActionService2> bindICodeActionService2() {
		ERDCodeActionService
	}

	def Class<? extends HoverService> bindHoverService() {
		ERDHoverService
	}

}
