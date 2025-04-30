from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from final_project.db import get_db
from final_project.schemas.user_activity import (
    UserActivityResponse,
    ActivityStats,
    ActivityType,
    EntityType
)
from final_project.services.user_activity import (
    get_user_activities,
    get_entity_activity_history,
    get_activity_stats
)
from final_project.security import get_current_user

router = APIRouter(prefix="/user-activities", tags=["user-activities"])

# Endpoint to get activity history for a specific user (accessible by the user or superuser)
@router.get("/user/{user_id}", response_model=List[UserActivityResponse])
def get_user_activity_history(
    user_id: int = Path(..., description="The user ID"),
    activity_type: Optional[str] = Query(None, description="Filter by activity type"),
    start_date: Optional[datetime] = Query(None, description="Start date for filtering"),
    end_date: Optional[datetime] = Query(None, description="End date for filtering"),
    limit: int = Query(100, description="Maximum number of activities to return"),
    offset: int = Query(0, description="Number of activities to skip"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Ensure only the user or superuser can access
    if user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized to view activity history for other users")

    # Validate activity type if provided
    if activity_type and activity_type not in [t.value for t in ActivityType]:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid activity type. Must be one of: {', '.join([t.value for t in ActivityType])}"
        )

    return get_user_activities(
        db=db,
        user_id=user_id,
        activity_type=activity_type,
        start_date=start_date,
        end_date=end_date,
        limit=limit,
        offset=offset
    )

# Endpoint to get activity history for a specific entity (accessible by authenticated users)
@router.get("/entity/{entity_type}/{entity_id}", response_model=List[UserActivityResponse])
def get_entity_history(
    entity_type: str = Path(..., description="The entity type"),
    entity_id: int = Path(..., description="The entity ID"),
    limit: int = Query(50, description="Maximum number of activities to return"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Validate entity type
    if entity_type not in [t.value for t in EntityType]:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid entity type. Must be one of: {', '.join([t.value for t in EntityType])}"
        )

    return get_entity_activity_history(
        db=db,
        entity_id=entity_id,
        entity_type=entity_type,
        limit=limit
    )

# Endpoint to get activity statistics (accessible by the user or superuser)
@router.get("/stats", response_model=ActivityStats)
def get_activity_statistics(
    user_id: Optional[int] = Query(None, description="Filter by user ID"),
    days: int = Query(30, description="Number of days to analyze"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Restrict regular users to their own stats
    if user_id is not None and user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized to view activity statistics for other users")

    # If user_id is not provided and the user is not superuser, default to current user
    if user_id is None and not current_user.superuser:
        user_id = current_user.user_id

    return get_activity_stats(db=db, user_id=user_id, days=days)

# Endpoint to get system-wide activity statistics (accessible by superuser only)
@router.get("/system/stats", response_model=ActivityStats)
def get_system_activity_statistics(
    days: int = Query(30, description="Number of days to analyze"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Ensure only superusers can access system-wide stats
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    return get_activity_stats(db=db, days=days)