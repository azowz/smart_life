from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func

from final_project.models.ai_feedback import AIFeedbackDB
from final_project.schemas.ai_feedback import AIFeedbackCreate, AIFeedbackUpdate

def create_feedback(db: Session, feedback_data: AIFeedbackCreate) -> AIFeedbackDB:
    """
    Create a new AI feedback entry

    Args:
        db: SQLAlchemy database session
        feedback_data: Feedback data

    Returns:
        The created feedback entry
    """
    # Check if feedback already exists for this interaction and user
    existing_feedback = db.query(AIFeedbackDB).filter(
        AIFeedbackDB.interaction_id == feedback_data.interaction_id,
        AIFeedbackDB.user_id == feedback_data.user_id
    ).first()

    if existing_feedback:
        # Update existing feedback instead of creating new
        existing_feedback.rating = feedback_data.rating
        existing_feedback.feedback_text = feedback_data.feedback_text
        db.commit()
        db.refresh(existing_feedback)
        return existing_feedback

    # Create new feedback
    db_feedback = AIFeedbackDB(**feedback_data.dict())
    db.add(db_feedback)
    db.commit()
    db.refresh(db_feedback)
    return db_feedback

def update_feedback(db: Session, feedback_id: int, feedback_data: AIFeedbackUpdate) -> Optional[AIFeedbackDB]:
    """
    Update an existing feedback entry

    Args:
        db: SQLAlchemy database session
        feedback_id: ID of the feedback to update
        feedback_data: Feedback update data

    Returns:
        The updated feedback entry or None if not found
    """
    db_feedback = db.query(AIFeedbackDB).filter(
        AIFeedbackDB.feedback_id == feedback_id
    ).first()

    if not db_feedback:
        return None

    # Update only the fields that are provided
    update_data = feedback_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_feedback, key, value)

    db.commit()
    db.refresh(db_feedback)
    return db_feedback

def mark_feedback_as_used(db: Session, feedback_id: int) -> Optional[AIFeedbackDB]:
    """
    Mark a feedback entry as used for improvement

    Args:
        db: SQLAlchemy database session
        feedback_id: ID of the feedback to mark

    Returns:
        The updated feedback entry or None if not found
    """
    db_feedback = db.query(AIFeedbackDB).filter(
        AIFeedbackDB.feedback_id == feedback_id
    ).first()

    if not db_feedback:
        return None

    db_feedback.is_used_for_improvement = True
    db.commit()
    db.refresh(db_feedback)
    return db_feedback

def get_feedback(db: Session, feedback_id: int) -> Optional[AIFeedbackDB]:
    """
    Get a specific feedback entry by ID

    Args:
        db: SQLAlchemy database session
        feedback_id: The feedback ID

    Returns:
        The feedback entry or None if not found
    """
    return db.query(AIFeedbackDB).filter(AIFeedbackDB.feedback_id == feedback_id).first()

def get_feedback_for_interaction(db: Session, interaction_id: int) -> List[AIFeedbackDB]:
    """
    Get all feedback for a specific interaction

    Args:
        db: SQLAlchemy database session
        interaction_id: The interaction ID

    Returns:
        List of feedback entries
    """
    return db.query(AIFeedbackDB).filter(
        AIFeedbackDB.interaction_id == interaction_id
    ).all()

def get_feedback_for_user(db: Session, user_id: int, limit: int = 50, offset: int = 0) -> List[AIFeedbackDB]:
    """
    Get all feedback provided by a specific user

    Args:
        db: SQLAlchemy database session
        user_id: The user ID
        limit: Maximum number of entries to return
        offset: Number of entries to skip

    Returns:
        List of feedback entries
    """
    return db.query(AIFeedbackDB).filter(
        AIFeedbackDB.user_id == user_id
    ).order_by(
        AIFeedbackDB.created_at.desc()
    ).limit(limit).offset(offset).all()

def get_unused_feedback(db: Session, limit: int = 100) -> List[AIFeedbackDB]:
    """
    Get feedback that hasn't been used for improvement yet

    Args:
        db: SQLAlchemy database session
        limit: Maximum number of entries to return

    Returns:
        List of unused feedback entries
    """
    return db.query(AIFeedbackDB).filter(
        AIFeedbackDB.is_used_for_improvement == False
    ).order_by(
        AIFeedbackDB.rating.asc(),  # Get lowest ratings first
        AIFeedbackDB.created_at.desc()
    ).limit(limit).all()

def get_feedback_stats(db: Session) -> Dict[str, Any]:
    """
    Get statistics about AI feedback

    Args:
        db: SQLAlchemy database session

    Returns:
        Dictionary with statistics
    """
    # Get average rating
    avg_rating = db.query(
        func.avg(AIFeedbackDB.rating)
    ).scalar() or 0

    # Get rating distribution
    rating_counts = db.query(
        AIFeedbackDB.rating,
        func.count().label('count')
    ).group_by(
        AIFeedbackDB.rating
    ).all()

    # Format rating distribution
    rating_distribution = {rating: 0 for rating in range(1, 6)}
    for rating, count in rating_counts:
        rating_distribution[rating] = count

    # Get total feedback count
    total_count = db.query(func.count(AIFeedbackDB.feedback_id)).scalar() or 0

    # Get count with text feedback
    text_feedback_count = db.query(func.count(AIFeedbackDB.feedback_id)).filter(
        AIFeedbackDB.feedback_text.isnot(None),
        AIFeedbackDB.feedback_text != ''
    ).scalar() or 0

    return {
        'average_rating': round(avg_rating, 2),
        'rating_distribution': rating_distribution,
        'total_feedback_count': total_count,
        'text_feedback_count': text_feedback_count,
        'text_feedback_percentage': round((text_feedback_count / total_count * 100) if total_count else 0, 2)
    }

def delete_feedback(db: Session, feedback_id: int) -> bool:
    """
    Delete a feedback entry

    Args:
        db: SQLAlchemy database session
        feedback_id: The feedback ID

    Returns:
        True if deleted successfully, False otherwise
    """
    db_feedback = db.query(AIFeedbackDB).filter(AIFeedbackDB.feedback_id == feedback_id).first()
    if not db_feedback:
        return False
    
    db.delete(db_feedback)
    db.commit()
    return True