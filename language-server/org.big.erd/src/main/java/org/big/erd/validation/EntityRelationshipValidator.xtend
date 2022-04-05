/*
 * generated by Xtext 2.24.0
 */
package org.big.erd.validation

import org.big.erd.entityRelationship.Model
import org.big.erd.entityRelationship.NotationOption
import org.big.erd.entityRelationship.EntityRelationshipPackage
import com.google.common.collect.Multimaps
import org.eclipse.xtext.validation.Check
import org.big.erd.entityRelationship.AttributeType
import org.apache.log4j.Logger
import org.big.erd.entityRelationship.CardinalityType
import org.big.erd.entityRelationship.RelationEntity
import org.big.erd.entityRelationship.Relationship
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EObject

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class EntityRelationshipValidator extends AbstractEntityRelationshipValidator {
	
	 static val LOG = Logger.getLogger(EntityRelationshipValidator)
	
    @Check
	def checkCardinality(Model model) {
     
		model.relationships.forEach [ r |
			val firstElement = r.first
			val secondElement = r.second
			val thirdElement = r.third
			
			if(model.notationOption.equals(NotationOption.MINMAX)){
				checkMinMaxCardinality(firstElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__FIRST)
				checkMinMaxCardinality(secondElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__SECOND)
				checkMinMaxCardinality(thirdElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__THIRD)
				
			}else if(model.notationOption.equals(NotationOption.CHEN)){
				checkChenCardinality(firstElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__FIRST)
				checkChenCardinality(secondElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__SECOND)
				checkChenCardinality(thirdElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__THIRD)
				
			} else if(model.notationOption.equals(NotationOption.BACHMAN)){
				checkBachmanCardinality(firstElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__FIRST)
				checkBachmanCardinality(secondElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__SECOND)
				checkBachmanCardinality(thirdElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__THIRD)
			} else if(model.notationOption.equals(NotationOption.CROWSFOOT)){
				if(secondElement === null){
					info('''Relationship: Second element of relation required.''', r, EntityRelationshipPackage.Literals.RELATIONSHIP__FIRST)
				} else if(thirdElement !== null){
					info('''Relationship: No third element allowed.''', r, EntityRelationshipPackage.Literals.RELATIONSHIP__THIRD)
				}else{
					checkCrowsFootCardinality(firstElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__FIRST)
					checkCrowsFootCardinality(secondElement, r, EntityRelationshipPackage.Literals.RELATIONSHIP__SECOND)
				}
			}
		]
    }
    
    def checkMinMaxCardinality(RelationEntity relationEntity, Relationship relationship, EStructuralFeature feature) {
		if (relationEntity !== null) {
			if (relationEntity.minMax === null || relationEntity.minMax.length < 3) {
				info('''Wrong cardinality.Usage: [n1,n2], [n1,*] or [*,n1]''', relationship, feature)
			}
			if (relationEntity.minMax.toString.length === 3) {
				var n1 = relationEntity.minMax.toString.substring(0, 1);
				var n2 = relationEntity.minMax.toString.substring(2, 3);

				if (n1.matches("\\d+") && n2.matches("\\d+") && Integer.parseInt(n1) > Integer.parseInt(n2)) {
					info('''Wrong cardinality. Usage: [n1,n2] n1 <= n2''', relationship, feature)
				}
			}
		}
	}
    
    def checkChenCardinality(RelationEntity relationEntity, Relationship relationship, EStructuralFeature feature){
    	if(relationEntity !== null && (relationEntity.cardinality === null || 
    								   relationEntity.cardinality === CardinalityType.ZERO ||
    								   relationEntity.cardinality === CardinalityType.ONE_OR_MORE || 
    								   relationEntity.cardinality === CardinalityType.ZERO_OR_MORE ||
    								   relationEntity.minMax !== null || 
    								   relationEntity.customMultiplicity !== null)){
			info('''Wrong cardinality. Usage: [1],[N] or [M]''', relationship, feature)
		}
    }
    
    def checkBachmanCardinality(RelationEntity relationEntity, Relationship relationship, EStructuralFeature feature) {
		if (relationEntity !== null && (relationEntity.cardinality === null || 
										relationEntity.customMultiplicity !== null ||
			 							relationEntity.minMax !== null || 
			 							relationEntity.cardinality === CardinalityType.MANY ||
			 							relationEntity.cardinality === CardinalityType.MANY_CHEN)) {
			info('''Wrong cardinality. Usage: [0],[0+],[1] or [1+]''', relationship, feature)
		}
	}
    
     def checkCrowsFootCardinality(RelationEntity relationEntity, Relationship relationship, EStructuralFeature feature){
    	if(relationEntity !== null && (relationEntity.cardinality === null || 
    								   relationEntity.customMultiplicity !== null || 
    								   relationEntity.minMax !== null || 
    								   relationEntity.cardinality === CardinalityType.MANY_CHEN ||
    								   relationEntity.cardinality === CardinalityType.MANY ||
    								   relationEntity.cardinality === CardinalityType.ZERO)){
			info('''Wrong cardinality. Usage: [1],[0+],[1+] or [?]''',relationship, feature)
		}
    }
	
	// Names are unique for entities and relationships
    @Check
	def uniqueNames(Model model) {
        // Entities
        val entityNames = Multimaps.index(model.entities, [name ?: ''])
        entityNames.keySet.forEach [ name |
        	val commonName = entityNames.get(name)
			if (commonName.size > 1) 
				commonName.forEach [
					error('''Multiple entites named '«name»'«».''', it, EntityRelationshipPackage.Literals.ENTITY__NAME)
			]
		]
		// Relationships
		val relNames = Multimaps.index(model.relationships, [name ?: ''])
        relNames.keySet.forEach [ name |
			val commonName = relNames.get(name)
			if (commonName.size > 1) 
				commonName.forEach [
					error('''Multiple relationships named '«name»'«».''', it, EntityRelationshipPackage.Literals.RELATIONSHIP__NAME)
			]
		]
    }
    
	// Check if strong entities contain primary key and no partial key
	@Check
	def containsKey(Model model) {
		val entities = model.entities?.filter[e | !e.weak]
        entities.forEach [ e |
			val attributes = e.attributes?.filter[a | a.type === AttributeType.KEY]
			val keyAttributes = e.attributes?.filter[a | a.type == AttributeType.PARTIAL_KEY]
			if (attributes.size < 1) 
				info('''Strong Entity '«e.name»'«» does not contain a primary key''', e, EntityRelationshipPackage.Literals.ENTITY__NAME)
			if (keyAttributes.size > 0) 
				info('''Strong Entity '«e.name»'«» is not allowed to have a partial key''', e, EntityRelationshipPackage.Literals.ENTITY__NAME)
		]
    }

	// Check if weak entities contain partial key and no primary key
	@Check
	def containsPartialKey(Model model) {
		val entities = model.entities?.filter[e | e.weak]
        entities.forEach [ e |
			val attributes = e.attributes?.filter[a | a.type == AttributeType.PARTIAL_KEY]
			val keyAttributes = e.attributes?.filter[a | a.type == AttributeType.KEY]
			if (attributes.size < 1) 
				info('''Weak Entity '«e.name»'«» does not contain a partial key''', e, EntityRelationshipPackage.Literals.ENTITY__NAME)
			if (keyAttributes.size > 0) 
				info('''Weak Entity '«e.name»'«» is not allowed to have a primary key''', e, EntityRelationshipPackage.Literals.ENTITY__NAME)
		]
    }
    
    /* TODO: Fix this? Scoping already handles available entities‚
    @Check
	def checkNoCycleInheritance(Entity entity) {
		// dont check if entity does not extend
		if (entity.extends === null)
			return
		
		val visitedEntities = newHashSet(entity)
		var current = entity.extends
		while (current !== null) {
			if (visitedEntities.contains(current)) {
				error('''Cycle in the inheritance of entity '«current.name»' ''', current, EntityRelationshipPackage.Literals.ENTITY__EXTENDS)
			}
			visitedEntities.add(current)
			current = current.extends
		}
	}
	*/
}
