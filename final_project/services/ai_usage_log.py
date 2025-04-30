from typing import Optional, List
from datetime import date, timedelta
from sqlalchemy import func, case

from final_project.models.ai_usage_log import AIUsageLogDB
from final_project.models.ai_interaction import AIInteractionDB
from final_project.schemas.ai_usage_log import AIUsageLogCreate

def create_or_update_usage_log(db_session, log_data: AIUsageLogCreate):
    """
    Create or update an AI usage log entry
    
    Args:
        db_session: SQLAlchemy database session
        log_data: AI usage log data
        
    Returns:
        The created or updated log entry
    """
    # Check if log entry already exists for this date
    existing_log = db_session.query(AIUsageLogDB).filter(
        AIUsageLogDB.date == log_data.date
    ).first()
    
    if existing_log:
        # Update existing log
        for key, value in log_data.dict().items():
            setattr(existing_log, key, value)
        db_session.commit()
        db_session.refresh(existing_log)
        return existing_log
    else:
        # Create new log entry
        db_log = AIUsageLogDB(**log_data.dict())
        db_session.add(db_log)
        db_session.commit()
        db_session.refresh(db_log)
        return db_log

def calculate_daily_ai_usage(db_session, target_date: date):
    """
    Calculate AI usage metrics for a specific date and save to log
    
    Args:
        db_session: SQLAlchemy database session
        target_date: The date to calculate metrics for
        
    Returns:
        The created or updated log entry
    """
    # Get metrics from ai_interactions table for the target date
    metrics = db_session.query(
        func.count(AIInteractionDB.interaction_id).label('total_req'),
        func.coalesce(func.sum(AIInteractionDB.tokens_used), 0).label('total_tokens'),
        func.coalesce(func.avg(AIInteractionDB.processing_time), 0).label('avg_response'),
        func.coalesce(
            func.sum(case([(AIInteractionDB.was_successful, 1)], else_=0)) * 100.0 / 
            func.nullif(func.count(AIInteractionDB.interaction_id), 0),
            0
        ).label('success_percentage'),
        func.coalesce(
            func.sum(case([(AIInteractionDB.was_successful == False, 1)], else_=0)),
            0
        ).label('error_count')
    ).filter(
        func.date(AIInteractionDB.created_at) == target_date
    ).first()
    
    # Calculate cost (example formula: $0.002 per 1000 tokens)
    cost_val = (metrics.total_tokens / 1000.0) * 0.002
    
    # Get error details
    error_details_query = db_session.query(
        func.coalesce(func.substring(AIInteractionDB.prompt, 1, 50), 'Unknown').label('error_type'),
        func.count().label('count')
    ).filter(
        func.date(AIInteractionDB.created_at) == target_date,
        AIInteractionDB.was_successful == False
    ).group_by('error_type').all()
    
    error_details = [{'error_type': err.error_type, 'count': err.count} for err in error_details_query]
    
    # Create or update log entry
    log_data = AIUsageLogCreate(
        date=target_date,
        total_requests=metrics.total_req,
        tokens_consumed=metrics.total_tokens,
        success_rate=round(metrics.success_percentage, 2),
        average_response_time=int(metrics.avg_response),
        cost=round(cost_val, 2),
        error_count=metrics.error_count,
        error_details=error_details
    )
    
    return create_or_update_usage_log(db_session, log_data)

def recalculate_ai_usage_range(db_session, start_date: date, end_date: date):
    """
    Recalculate AI usage metrics for a date range
    
    Args:
        db_session: SQLAlchemy database session
        start_date: Start date for recalculation
        end_date: End date for recalculation
        
    Returns:
        Number of days processed
    """
    current_date = start_date
    days_processed = 0
    
    while current_date <= end_date:
        calculate_daily_ai_usage(db_session, current_date)
        current_date += timedelta(days=1)
        days_processed += 1
    
    return days_processed

def get_ai_usage_logs(db_session, start_date: Optional[date] = None, end_date: Optional[date] = None) -> List[AIUsageLogDB]:
    """
    Get AI usage logs for a date range
    
    Args:
        db_session: SQLAlchemy database session
        start_date: Optional start date for filtering
        end_date: Optional end date for filtering
        
    Returns:
        List of AI usage logs
    """
    query = db_session.query(AIUsageLogDB)
    
    if start_date:
        query = query.filter(AIUsageLogDB.date >= start_date)
    
    if end_date:
        query = query.filter(AIUsageLogDB.date <= end_date)
    
    return query.order_by(AIUsageLogDB.date.desc()).all()

def get_ai_usage_log(db_session, log_id: int):
    """
    Get a specific AI usage log by ID
    
    Args:
        db_session: SQLAlchemy database session
        log_id: The log ID
        
    Returns:
        The AI usage log or None if not found
    """
    return db_session.query(AIUsageLogDB).filter(
        AIUsageLogDB.log_id == log_id
    ).first()

def get_usage_log_by_date(db_session, log_date: date):
    """
    Get an AI usage log for a specific date
    
    Args:
        db_session: SQLAlchemy database session
        log_date: The date to retrieve
        
    Returns:
        The AI usage log or None if not found
    """
    return db_session.query(AIUsageLogDB).filter(
        AIUsageLogDB.date == log_date
    ).first()

def get_total_cost(db_session, start_date: Optional[date] = None, end_date: Optional[date] = None) -> float:
    """
    Get total AI usage cost for a date range
    
    Args:
        db_session: SQLAlchemy database session
        start_date: Optional start date for filtering
        end_date: Optional end date for filtering
        
    Returns:
        Total cost
    """
    query = db_session.query(func.sum(AIUsageLogDB.cost))
    
    if start_date:
        query = query.filter(AIUsageLogDB.date >= start_date)
    
    if end_date:
        query = query.filter(AIUsageLogDB.date <= end_date)
    
    result = query.scalar() or 0.00
    return float(result)