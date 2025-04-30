from fastapi import APIRouter, Depends, HTTPException, Query, Path
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_db
from final_project.schemas.ai_interaction import (
    AIInteractionCreate,
    AIInteractionComplete,
    AIInteractionResponse,
    AIInteractionStats,
    InteractionType
)
from final_project.services.ai_interaction import (
    create_interaction,
    complete_interaction,
    get_interaction,
    get_user_interactions,
    get_interactions_by_type,
    get_interaction_stats
)
from final_project.security import get_current_user

router = APIRouter(prefix="/ai-interactions", tags=["ai-interactions"])

@router.post("/", response_model=AIInteractionResponse, status_code=201)
def create_ai_interaction(
    interaction: AIInteractionCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Create a new AI interaction (start of the process)
    
    This endpoint initiates an AI interaction but does not include the response.
    Use the complete endpoint to add the response data.
    """
    # Check if user is authorized to create this interaction
    if interaction.user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to create interactions for other users")
    
    return create_interaction(db=db, interaction_data=interaction)

@router.put("/{interaction_id}/complete", response_model=AIInteractionResponse)
def complete_ai_interaction(
    interaction_id: int = Path(..., description="The interaction ID"),
    completion: AIInteractionComplete = ...,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Complete an AI interaction by adding response data
    """
    # Check if interaction exists
    interaction = get_interaction(db=db, interaction_id=interaction_id)
    if not interaction:
        raise HTTPException(status_code=404, detail="Interaction not found")
    
    # Check if user is authorized to complete this interaction
    if interaction.user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to complete this interaction")
    
    return complete_interaction(db=db, interaction_id=interaction_id, completion_data=completion)

@router.get("/user/{user_id}", response_model=List[AIInteractionResponse])
def get_user_ai_interactions(
    user_id: int = Path(..., description="The user ID"),
    limit: int = Query(50, description="Maximum number of interactions to return"),
    offset: int = Query(0, description="Number of interactions to skip"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get interactions for a specific user
    """
    # Check if user is authorized to view these interactions
    if user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to view interactions for other users")
    
    return get_user_interactions(db=db, user_id=user_id, limit=limit, offset=offset)

@router.get("/stats", response_model=AIInteractionStats)
def get_ai_interaction_stats(
    user_id: Optional[int] = Query(None, description="Optional user ID to filter by"),
    days: int = Query(30, description="Number of days to look back"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get statistics about AI interactions
    """
    # Check if user is authorized to view stats for other users
    if user_id is not None and user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to view statistics for other users")
    
    # If no user_id provided and not admin, use current user's ID
    if user_id is None and not current_user.get("is_superuser", False):
        user_id = current_user["user_id"]
    
    return get_interaction_stats(db=db, user_id=user_id, days=days)

@router.get("/{interaction_id}", response_model=AIInteractionResponse)
def get_ai_interaction(
    interaction_id: int = Path(..., description="The interaction ID"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get a specific AI interaction by ID
    """
    interaction = get_interaction(db=db, interaction_id=interaction_id)
    if not interaction:
        raise HTTPException(status_code=404, detail="Interaction not found")
    
    # Check if user is authorized to view this interaction
    if interaction.user_id != current_user["user_id"] and not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Not authorized to view this interaction")
    
    return interaction

@router.get("/type/{interaction_type}", response_model=List[AIInteractionResponse])
def get_interactions_by_interaction_type(
    interaction_type: str = Path(..., description="The interaction type"),
    limit: int = Query(50, description="Maximum number of interactions to return"),
    offset: int = Query(0, description="Number of interactions to skip"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Get interactions of a specific type (admin only)
    """
    # Only admins can view all interactions of a specific type
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only administrators can view all interactions by type")
    
    # Validate interaction type
    if interaction_type not in [t.value for t in InteractionType]:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid interaction type. Must be one of: {', '.join([t.value for t in InteractionType])}"
        )
    
    return get_interactions_by_type(db=db, interaction_type=interaction_type, limit=limit, offset=offset)