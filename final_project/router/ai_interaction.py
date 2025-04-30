from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_db
from final_project.models.user import UserDB
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

# Create a new AI interaction
@router.post("/", response_model=AIInteractionResponse, status_code=201)
async def create_ai_interaction(
    interaction: AIInteractionCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    if interaction.user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    return create_interaction(db=db, interaction_data=interaction)

# Complete an existing interaction (generate AI response)
@router.put("/{interaction_id}/complete", response_model=AIInteractionResponse)
async def complete_ai_interaction(
    interaction_id: int,
    completion: AIInteractionComplete,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    interaction = get_interaction(db, interaction_id)
    if not interaction:
        raise HTTPException(status_code=404, detail="Interaction not found")

    if interaction.user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Unauthorized")

    return await complete_interaction(db=db, interaction_id=interaction_id, completion_data=completion)

# Retrieve all interactions for a specific user
@router.get("/user/{user_id}", response_model=List[AIInteractionResponse])
def get_user_ai_interactions(
    user_id: int,
    limit: int = Query(50, description="Max number of interactions"),
    offset: int = Query(0, description="Offset for pagination"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    if user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    return get_user_interactions(db, user_id, limit, offset)

# Get interaction statistics (global or per user)
@router.get("/stats", response_model=AIInteractionStats)
def get_ai_interaction_stats(
    user_id: Optional[int] = Query(None),
    days: int = Query(30, description="Number of days to include in stats"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    if user_id and user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    if user_id is None and not current_user.superuser:
        user_id = current_user.user_id
    return get_interaction_stats(db, user_id, days)

# Retrieve a single interaction by ID
@router.get("/{interaction_id}", response_model=AIInteractionResponse)
def get_ai_interaction(
    interaction_id: int,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    interaction = get_interaction(db, interaction_id)
    if not interaction:
        raise HTTPException(status_code=404, detail="Interaction not found")

    if interaction.user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Unauthorized")

    return interaction

# Retrieve interactions by interaction type (admin only)
@router.get("/type/{interaction_type}", response_model=List[AIInteractionResponse])
def get_interactions_by_interaction_type(
    interaction_type: str,
    limit: int = Query(50),
    offset: int = Query(0),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Only superusers can access this route")

    if interaction_type not in [t.value for t in InteractionType]:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid interaction type. Valid types: {[t.value for t in InteractionType]}"
        )

    return get_interactions_by_type(db, interaction_type, limit, offset)
