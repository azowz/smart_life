from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from datetime import datetime, timedelta
from enum import Enum

from final_project.models.ai_interaction import AIInteractionDB
from final_project.schemas.ai_interaction import AIInteractionCreate, AIInteractionComplete

def create_interaction(db: Session, interaction_data: AIInteractionCreate) -> AIInteractionDB:
    """
    Create a new AI interaction (start of the process)

    Args:
        db: SQLAlchemy database session
        interaction_data: Interaction data

    Returns:
        The created interaction
    """
    # Convert Pydantic model to dict and handle Enum values
    interaction_dict = interaction_data.dict()
    if isinstance(interaction_dict.get('interaction_type'), Enum):
        interaction_dict['interaction_type'] = interaction_dict['interaction_type'].value

    db_interaction = AIInteractionDB(**interaction_dict)
    db.add(db_interaction)
    db.commit()
    db.refresh(db_interaction)
    return db_interaction

def complete_interaction(
    db: Session, 
    interaction_id: int, 
    completion_data: AIInteractionComplete
) -> Optional[AIInteractionDB]:
    """
    Complete an AI interaction by adding response data

    Args:
        db: SQLAlchemy database session
        interaction_id: ID of the interaction to complete
        completion_data: Completion data

    Returns:
        The updated interaction or None if not found
    """
    db_interaction = db.query(AIInteractionDB).filter(
        AIInteractionDB.interaction_id == interaction_id
    ).first()

    if not db_interaction:
        return None

    # Update with completion data
    db_interaction.response = completion_data.response
    db_interaction.processing_time = completion_data.processing_time
    db_interaction.tokens_used = completion_data.tokens_used
    db_interaction.was_successful = completion_data.was_successful

    db.commit()
    db.refresh(db_interaction)
    return db_interaction

def get_user_interactions(
    db: Session, 
    user_id: int, 
    limit: int = 50, 
    offset: int = 0
) -> List[AIInteractionDB]:
    """
    Get interactions for a specific user

    Args:
        db: SQLAlchemy database session
        user_id: The user ID
        limit: Maximum number of interactions to return
        offset: Number of interactions to skip

    Returns:
        List of interactions
    """
    return db.query(AIInteractionDB).filter(
        AIInteractionDB.user_id == user_id
    ).order_by(
        AIInteractionDB.created_at.desc()
    ).limit(limit).offset(offset).all()

def get_interaction_stats(
    db: Session, 
    user_id: Optional[int] = None, 
    days: int = 30
) -> Dict[str, Any]:
    """
    Get statistics about AI interactions

    Args:
        db: SQLAlchemy database session
        user_id: Optional user ID to filter by
        days: Number of days to look back

    Returns:
        Dictionary with statistics
    """
    start_date = datetime.now() - timedelta(days=days)

    # Base query
    query = db.query(
        func.count().label('total_interactions'),
        func.sum(case([(AIInteractionDB.was_successful, 1)], else_=0)).label('successful_interactions'),
        func.sum(AIInteractionDB.tokens_used).label('total_tokens'),
        func.avg(AIInteractionDB.processing_time).label('avg_processing_time')
    ).filter(
        AIInteractionDB.created_at >= start_date
    )

    # Add user filter if provided
    if user_id:
        query = query.filter(AIInteractionDB.user_id == user_id)

    # Execute query
    result = query.first()

    # Format result
    return {
        'total_interactions': result.total_interactions or 0,
        'successful_interactions': result.successful_interactions or 0,
        'success_rate': (result.successful_interactions / result.total_interactions * 100) if result.total_interactions else 0,
        'total_tokens': result.total_tokens or 0,
        'avg_processing_time': result.avg_processing_time or 0,
        'period_days': days,
        'user_id': user_id
    }

def get_interaction(db: Session, interaction_id: int) -> Optional[AIInteractionDB]:
    """
    Get a specific interaction by ID

    Args:
        db: SQLAlchemy database session
        interaction_id: The interaction ID

    Returns:
        The interaction or None if not found
    """
    return db.query(AIInteractionDB).filter(AIInteractionDB.interaction_id == interaction_id).first()

def get_interactions_by_type(
    db: Session, 
    interaction_type: str, 
    limit: int = 50, 
    offset: int = 0
) -> List[AIInteractionDB]:
    """
    Get interactions of a specific type

    Args:
        db: SQLAlchemy database session
        interaction_type: The interaction type
        limit: Maximum number of interactions to return
        offset: Number of interactions to skip

    Returns:
        List of interactions
    """
    return db.query(AIInteractionDB).filter(
        AIInteractionDB.interaction_type == interaction_type
    ).order_by(
        AIInteractionDB.created_at.desc()
    ).limit(limit).offset(offset).all()