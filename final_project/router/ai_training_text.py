from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_db
from final_project.schemas.ai_training_text import (
    AITrainingTextCreate,
    AITrainingTextUpdate,
    AITrainingTextResponse,
    ContentType
)
from final_project.services.ai_training_text import (
    create_training_text,
    update_training_text,
    get_training_text,
    get_training_texts,
    increment_usage_count,
    delete_training_text
)
from final_project.security import get_current_user

router = APIRouter(prefix="/ai-training-texts", tags=["ai-training-texts"])

@router.post("/", response_model=AITrainingTextResponse, status_code=201)
def create_text(
    text: AITrainingTextCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Create a new AI training text"""
    # Only admins can create training texts
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can create training texts")
    
    # Set the created_by field to the current user's ID if not provided
    if not text.created_by:
        text.created_by = current_user["user_id"]
    
    return create_training_text(db=db, text_data=text)

@router.get("/", response_model=List[AITrainingTextResponse])
def list_texts(
    content_type: Optional[str] = Query(None, description="Filter by content type"),
    category_id: Optional[int] = Query(None, description="Filter by category ID"),
    active_only: bool = Query(True, description="Only return active texts"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get all AI training texts, optionally filtered by content type and category"""
    # Validate content_type if provided
    if content_type and content_type not in [ct.value for ct in ContentType]:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid content type. Must be one of: {', '.join([ct.value for ct in ContentType])}"
        )
    
    return get_training_texts(
        db=db,
        content_type=content_type,
        category_id=category_id,
        active_only=active_only
    )

@router.get("/{text_id}", response_model=AITrainingTextResponse)
def get_text(
    text_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get a specific AI training text by ID"""
    text = get_training_text(db=db, text_id=text_id)
    if not text:
        raise HTTPException(status_code=404, detail="Training text not found")
    return text

@router.put("/{text_id}", response_model=AITrainingTextResponse)
def update_text(
    text_id: int,
    text: AITrainingTextUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Update an AI training text"""
    # Only admins can update training texts
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can update training texts")
    
    updated_text = update_training_text(db=db, text_id=text_id, text_data=text)
    if not updated_text:
        raise HTTPException(status_code=404, detail="Training text not found")
    return updated_text

@router.post("/{text_id}/increment", response_model=AITrainingTextResponse)
def increment_text_usage(
    text_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Increment the usage count for an AI training text"""
    text = get_training_text(db=db, text_id=text_id)
    if not text:
        raise HTTPException(status_code=404, detail="Training text not found")
    
    increment_usage_count(db=db, text_id=text_id)
    return get_training_text(db=db, text_id=text_id)

@router.delete("/{text_id}")
def delete_text(
    text_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Delete an AI training text"""
    # Only admins can delete training texts
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can delete training texts")
    
    success = delete_training_text(db=db, text_id=text_id)
    if not success:
        raise HTTPException(status_code=404, detail="Training text not found")
    return {"message": "Training text successfully deleted"}