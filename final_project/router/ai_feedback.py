from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_db

from final_project.schemas.ai_feedback import (    AIFeedbackCreate,
    AIFeedbackUpdate,
    AIFeedbackResponse,
    AIFeedbackStats
)
from final_project.services.ai_feedback import (
    create_feedback,
    update_feedback,
    get_feedback,
    get_feedback_for_interaction,
    get_feedback_for_user,
    get_unused_feedback,
    mark_feedback_as_used,
    get_feedback_stats,
    delete_feedback
)
from final_project.security import get_current_user

router = APIRouter(prefix="/ai-feedback", tags=["ai-feedback"])

@router.post("/", response_model=AIFeedbackResponse, status_code=201)
def create_ai_feedback(
    feedback: AIFeedbackCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Create a new AI feedback entry.
    If feedback already exists for this interaction and user, it will be updated instead.
    """
    # Check if user is authorized to create this feedback
    if feedback.user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to submit feedback for other users")
    
    return create_feedback(db=db, feedback_data=feedback)

@router.get("/interaction/{interaction_id}", response_model=List[AIFeedbackResponse])
def get_feedback_for_interaction_endpoint(
    interaction_id: int = Path(..., description="The interaction ID"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get all feedback for a specific interaction
    """
    # Feedback for an interaction can be viewed by the user who created the interaction or admins
    # This would require additional checks in a real application
    return get_feedback_for_interaction(db=db, interaction_id=interaction_id)

@router.get("/user/{user_id}", response_model=List[AIFeedbackResponse])
def get_feedback_for_user_endpoint(
    user_id: int = Path(..., description="The user ID"),
    limit: int = Query(50, description="Maximum number of entries to return"),
    offset: int = Query(0, description="Number of entries to skip"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get all feedback provided by a specific user
    """
    # Check if user is authorized to view this feedback
    if user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to view feedback for other users")
    
    return get_feedback_for_user(db=db, user_id=user_id, limit=limit, offset=offset)

@router.get("/unused", response_model=List[AIFeedbackResponse])
def get_unused_feedback_endpoint(
    limit: int = Query(100, description="Maximum number of entries to return"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get feedback that hasn't been used for improvement yet (admin only)
    """
    # Only admins can view unused feedback
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can view unused feedback")
    
    return get_unused_feedback(db=db, limit=limit)

@router.post("/{feedback_id}/mark-used", response_model=AIFeedbackResponse)
def mark_feedback_as_used_endpoint(
    feedback_id: int = Path(..., description="The feedback ID"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Mark a feedback entry as used for improvement (admin only)
    """
    # Only admins can mark feedback as used
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can mark feedback as used")
    
    updated_feedback = mark_feedback_as_used(db=db, feedback_id=feedback_id)
    if not updated_feedback:
        raise HTTPException(status_code=404, detail="Feedback not found")
    
    return updated_feedback

@router.get("/stats", response_model=AIFeedbackStats)
def get_feedback_stats_endpoint(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get statistics about AI feedback (admin only)
    """
    # Only admins can view feedback statistics
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can view feedback statistics")
    
    return get_feedback_stats(db=db)

@router.get("/{feedback_id}", response_model=AIFeedbackResponse)
def get_feedback_endpoint(
    feedback_id: int = Path(..., description="The feedback ID"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get a specific feedback entry by ID
    """
    feedback = get_feedback(db=db, feedback_id=feedback_id)
    if not feedback:
        raise HTTPException(status_code=404, detail="Feedback not found")
    
    # Check if user is authorized to view this feedback
    if feedback.user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to view this feedback")
    
    return feedback

@router.put("/{feedback_id}", response_model=AIFeedbackResponse)
def update_feedback_endpoint(
    feedback_id: int = Path(..., description="The feedback ID"),
    feedback_data: AIFeedbackUpdate = ...,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Update an existing feedback entry
    """
    # Check if feedback exists
    existing_feedback = get_feedback(db=db, feedback_id=feedback_id)
    if not existing_feedback:
        raise HTTPException(status_code=404, detail="Feedback not found")
    
    # Check if user is authorized to update this feedback
    if existing_feedback.user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to update this feedback")
    
    # Regular users can't mark feedback as used
    if feedback_data.is_used_for_improvement is not None and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can mark feedback as used")
    
    return update_feedback(db=db, feedback_id=feedback_id, feedback_data=feedback_data)

@router.delete("/{feedback_id}")
def delete_feedback_endpoint(
    feedback_id: int = Path(..., description="The feedback ID"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Delete a feedback entry
    """
    # Check if feedback exists
    existing_feedback = get_feedback(db=db, feedback_id=feedback_id)
    if not existing_feedback:
        raise HTTPException(status_code=404, detail="Feedback not found")
    
    # Check if user is authorized to delete this feedback
    if existing_feedback.user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to delete this feedback")
    
    success = delete_feedback(db=db, feedback_id=feedback_id)
    if not success:
        raise HTTPException(status_code=404, detail="Feedback not found")
    
    return {"message": "Feedback successfully deleted"}