from fastapi import APIRouter, Depends, HTTPException, Query, Path
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date, timedelta

from final_project.services.ai_usage_log import (
    create_or_update_usage_log,
    calculate_daily_ai_usage,
    recalculate_ai_usage_range,
    get_ai_usage_logs,
    get_ai_usage_log,
    get_usage_log_by_date,
    get_total_cost
)
from final_project.schemas.ai_usage_log import AIUsageLogCreate, AIUsageLogResponse
from final_project.db import get_db

router = APIRouter(prefix="/ai-usage-logs", tags=["AI Usage Logs"])

@router.post("/", response_model=AIUsageLogResponse)
def create_or_update_log(
    log_data: AIUsageLogCreate,
    db: Session = Depends(get_db)
):
    """
    Create or update an AI usage log entry
    """
    return create_or_update_usage_log(db, log_data)

@router.post("/calculate/{target_date}", response_model=AIUsageLogResponse)
def calculate_usage_for_date(
    target_date: date = Path(..., description="Date to calculate metrics for"),
    db: Session = Depends(get_db)
):
    """
    Calculate AI usage metrics for a specific date and save to log
    """
    return calculate_daily_ai_usage(db, target_date)

@router.post("/recalculate")
def recalculate_usage_range(
    start_date: date = Query(..., description="Start date for recalculation"),
    end_date: date = Query(..., description="End date for recalculation"),
    db: Session = Depends(get_db)
):
    """
    Recalculate AI usage metrics for a date range
    """
    days_processed = recalculate_ai_usage_range(db, start_date, end_date)
    return {"message": f"Recalculated AI usage metrics for {days_processed} days"}

@router.get("/", response_model=List[AIUsageLogResponse])
def get_usage_logs(
    start_date: Optional[date] = Query(None, description="Start date for filtering"),
    end_date: Optional[date] = Query(None, description="End date for filtering"),
    db: Session = Depends(get_db)
):
    """
    Get AI usage logs for a date range
    """
    return get_ai_usage_logs(db, start_date, end_date)

@router.get("/{log_id}", response_model=AIUsageLogResponse)
def get_log_by_id(
    log_id: int = Path(..., description="The ID of the log to retrieve"),
    db: Session = Depends(get_db)
):
    """
    Get a specific AI usage log by ID
    """
    log = get_ai_usage_log(db, log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Log not found")
    return log

@router.get("/date/{log_date}", response_model=AIUsageLogResponse)
def get_log_by_date(
    log_date: date = Path(..., description="The date to retrieve the log for"),
    db: Session = Depends(get_db)
):
    """
    Get an AI usage log for a specific date
    """
    log = get_usage_log_by_date(db, log_date)
    if not log:
        raise HTTPException(status_code=404, detail=f"No log found for date: {log_date}")
    return log

@router.get("/cost/total")
def get_cost(
    start_date: Optional[date] = Query(None, description="Start date for filtering"),
    end_date: Optional[date] = Query(None, description="End date for filtering"),
    db: Session = Depends(get_db)
):
    """
    Get total AI usage cost for a date range
    """
    total_cost = get_total_cost(db, start_date, end_date)
    period_desc = ""
    
    if start_date and end_date:
        period_desc = f"from {start_date} to {end_date}"
    elif start_date:
        period_desc = f"since {start_date}"
    elif end_date:
        period_desc = f"until {end_date}"
    else:
        period_desc = "for all time"
    
    return {
        "total_cost": total_cost,
        "message": f"Total AI usage cost {period_desc}: ${total_cost:.2f}"
    }

@router.post("/calculate/today", response_model=AIUsageLogResponse)
def calculate_today_usage(
    db: Session = Depends(get_db)
):
    """
    Calculate AI usage metrics for today and save to log
    """
    today = date.today()
    return calculate_daily_ai_usage(db, today)

@router.post("/calculate/yesterday", response_model=AIUsageLogResponse)
def calculate_yesterday_usage(
    db: Session = Depends(get_db)
):
    """
    Calculate AI usage metrics for yesterday and save to log
    """
    yesterday = date.today() - timedelta(days=1)
    return calculate_daily_ai_usage(db, yesterday)