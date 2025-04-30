from typing import List, Optional
from sqlalchemy.orm import Session
from enum import Enum

from final_project.models.ai_training_text import AITrainingTextDB
from final_project.schemas.ai_training_text import AITrainingTextCreate, AITrainingTextUpdate

def create_training_text(db: Session, text_data: AITrainingTextCreate) -> AITrainingTextDB:
    """
    Create a new training text

    Args:
        db: SQLAlchemy database session
        text_data: Training text data

    Returns:
        The created training text
    """
    # Convert Pydantic model to dict and handle Enum values
    text_dict = text_data.dict()
    if isinstance(text_dict.get('content_type'), Enum):
        text_dict['content_type'] = text_dict['content_type'].value

    db_text = AITrainingTextDB(**text_dict)
    db.add(db_text)
    db.commit()
    db.refresh(db_text)
    return db_text

def update_training_text(db: Session, text_id: int, text_data: AITrainingTextUpdate) -> Optional[AITrainingTextDB]:
    """
    Update an existing training text

    Args:
        db: SQLAlchemy database session
        text_id: ID of the text to update
        text_data: Text update data

    Returns:
        The updated training text or None if not found
    """
    db_text = db.query(AITrainingTextDB).filter(
        AITrainingTextDB.text_id == text_id
    ).first()

    if not db_text:
        return None

    # Update only the fields that are provided
    update_data = text_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        if isinstance(value, Enum):
            setattr(db_text, key, value.value)
        else:
            setattr(db_text, key, value)

    db.commit()
    db.refresh(db_text)
    return db_text

def increment_usage_count(db: Session, text_id: int) -> Optional[int]:
    """
    Increment the usage count for a training text

    Args:
        db: SQLAlchemy database session
        text_id: ID of the text

    Returns:
        The updated usage count or None if text not found
    """
    db_text = db.query(AITrainingTextDB).filter(
        AITrainingTextDB.text_id == text_id
    ).first()

    if not db_text:
        return None

    db_text.usage_count += 1
    db.commit()
    return db_text.usage_count

def get_training_texts(
    db: Session, 
    content_type: Optional[str] = None,
    category_id: Optional[int] = None, 
    active_only: bool = True
) -> List[AITrainingTextDB]:
    """
    Get training texts, optionally filtered by content type, category, and active status

    Args:
        db: SQLAlchemy database session
        content_type: Optional content type filter
        category_id: Optional category ID filter
        active_only: If True, return only active texts

    Returns:
        List of training texts
    """
    query = db.query(AITrainingTextDB)

    if content_type:
        query = query.filter(AITrainingTextDB.content_type == content_type)

    if category_id:
        query = query.filter(AITrainingTextDB.category_id == category_id)

    if active_only:
        query = query.filter(AITrainingTextDB.is_active == True)

    return query.order_by(AITrainingTextDB.effectiveness_rating.desc().nullslast()).all()

def get_training_text(db: Session, text_id: int) -> Optional[AITrainingTextDB]:
    """
    Get a training text by ID

    Args:
        db: SQLAlchemy database session
        text_id: The text ID

    Returns:
        The training text or None if not found
    """
    return db.query(AITrainingTextDB).filter(AITrainingTextDB.text_id == text_id).first()

def delete_training_text(db: Session, text_id: int) -> bool:
    """
    Delete a training text by ID

    Args:
        db: SQLAlchemy database session
        text_id: The text ID

    Returns:
        True if deleted successfully, False otherwise
    """
    db_text = db.query(AITrainingTextDB).filter(AITrainingTextDB.text_id == text_id).first()
    if not db_text:
        return False
    
    db.delete(db_text)
    db.commit()
    return True