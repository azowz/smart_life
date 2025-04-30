from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date

from final_project.services.system_statistics import (
    create_system_statistic,            # Service to create a new system statistic
    get_system_statistics,              # Service to retrieve system statistics with optional filters
    get_latest_stat_by_type,            # Service to get the latest stat for a specific type
    calculate_user_growth_statistics,   # Service to calculate user growth
    calculate_ai_usage_statistics       # Service to calculate AI usage stats
)
from final_project.schemas.system_statistics import SystemStatisticsCreate, SystemStatisticsResponse
from final_project.db import get_db
from final_project.security import get_current_user  # Import user dependency

router = APIRouter(prefix="/system-statistics", tags=["System Statistics"])

# Endpoint to create a new system statistic (superuser only)
@router.post("/", response_model=SystemStatisticsResponse)
def create_statistic(
    stat_data: SystemStatisticsCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Only superusers can create system statistics
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    return create_system_statistic(db, stat_data)

# Endpoint to get system statistics with optional filters (superuser only)
@router.get("/", response_model=List[SystemStatisticsResponse])
def get_statistics(
    stat_type: Optional[str] = Query(None, description="Filter by statistic type"),
    start_date: Optional[date] = Query(None, description="Start date for filtering"),
    end_date: Optional[date] = Query(None, description="End date for filtering"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Only superusers can view system statistics
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    return get_system_statistics(db, stat_type, start_date, end_date)

# Endpoint to get the latest statistic of a specific type (superuser only)
@router.get("/latest/{stat_type}", response_model=SystemStatisticsResponse)
def get_latest_statistic(
    stat_type: str,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Only superusers can access this endpoint
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    stat = get_latest_stat_by_type(db, stat_type)
    if not stat:
        raise HTTPException(status_code=404, detail=f"No statistics found for type: {stat_type}")
    
    return stat

# Endpoint to calculate and store user growth statistics (superuser only)
@router.post("/calculate/user-growth", response_model=SystemStatisticsResponse)
def calculate_user_growth(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Only superusers can calculate growth
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    return calculate_user_growth_statistics(db)

# Endpoint to calculate and store AI usage statistics (superuser only)
@router.post("/calculate/ai-usage", response_model=SystemStatisticsResponse)
def calculate_ai_usage(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Only superusers can calculate AI usage
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    return calculate_ai_usage_statistics(db)
