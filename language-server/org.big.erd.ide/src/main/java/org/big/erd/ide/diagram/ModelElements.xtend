package org.big.erd.ide.diagram

import org.eclipse.sprotty.SNode
import org.eclipse.sprotty.SEdge
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.sprotty.SGraph
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.sprotty.PreRenderedElement
import org.eclipse.sprotty.SButton

@Accessors
class ERModel extends SGraph {
	String name
	String generateType
  String notation

	new() { }
	
	new((ERModel) => void initializer) {
		initializer.apply(this)
	}
}


@Accessors
class EntityNode extends SNode {
	boolean expanded
	boolean weak
	
	new() { }
	
	new((EntityNode) => void initializer) {
		initializer.apply(this)
	}
}

@Accessors
class RelationshipNode extends SNode {
	boolean weak
	
	new() { }
	
	new((RelationshipNode) => void initializer) {
		initializer.apply(this)
	}
}

@Accessors
class NotationEdge extends SEdge {
	Boolean isSource
	String notation
	Boolean showRelationship
	String relationshipCardinality
	
	new() { }
	
	new((NotationEdge) => void initializer) {
		initializer.apply(this)
	}
}

@Accessors
class PopupButton extends PreRenderedElement {
	String target
	String kind

	new() { }
	
	new((PopupButton) => void initializer) {
		initializer.apply(this)
	}
}