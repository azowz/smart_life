from typing import Optional, List
from datetime import date
from sqlalchemy import func

from final_project.models.system_statistics import SystemStatisticsDB
from final_project.schemas.system_statistics import SystemStatisticsCreate
from final_project.models.user import UserDB
from final_project.models.ai_interaction import AIInteractionDB

def create_system_statistic(db_session, stat_data: SystemStatisticsCreate):
    """
    Create a new system statistic
    
    Args:
        db_session: SQLAlchemy database session
        stat_data: System statistic data
        
    Returns:
        The created system statistic
    """
    db_stat = SystemStatisticsDB(**stat_data.dict())
    db_session.add(db_stat)
    db_session.commit()
    db_session.refresh(db_stat)
    return db_stat

def get_system_statistics(db_session, stat_type: Optional[str] = None, 
                         start_date: Optional[date] = None, end_date: Optional[date] = None) -> List[SystemStatisticsDB]:
    """
    Get system statistics with optional filtering
    
    Args:
        db_session: SQLAlchemy database session
        stat_type: Optional statistic type filter
        start_date: Optional start date for filtering
        end_date: Optional end date for filtering
        
    Returns:
        List of system statistics
    """
    query = db_session.query(SystemStatisticsDB)
    
    if stat_type:
        query = query.filter(SystemStatisticsDB.stat_type == stat_type)
    
    if start_date:
        query = query.filter(SystemStatisticsDB.date >= start_date)
    
    if end_date:
        query = query.filter(SystemStatisticsDB.date <= end_date)
    
    return query.order_by(
        SystemStatisticsDB.date.desc(),
        SystemStatisticsDB.stat_type
    ).all()

def get_latest_stat_by_type(db_session, stat_type: str) -> Optional[SystemStatisticsDB]:
    """
    Get the latest statistic of a specific type
    
    Args:
        db_session: SQLAlchemy database session
        stat_type: The statistic type
        
    Returns:
        The latest statistic or None if not found
    """
    return db_session.query(SystemStatisticsDB).filter(
        SystemStatisticsDB.stat_type == stat_type
    ).order_by(
        SystemStatisticsDB.date.desc()
    ).first()

def calculate_user_growth_statistics(db_session):
    """
    Calculate and store user growth statistics
    
    Args:
        db_session: SQLAlchemy database session
        
    Returns:
        The created system statistic
    """
    today = date.today()
    
    # Get total user count
    total_users = db_session.query(func.count(UserDB.user_id)).filter(
        UserDB.is_active == True
    ).scalar() or 0
    
    # Get new users in the last day
    new_users_today = db_session.query(func.count(UserDB.user_id)).filter(
        func.date(UserDB.created_at) == today
    ).scalar() or 0
    
    # Get active users in the last day
    active_users_today = db_session.query(func.count(UserDB.user_id)).filter(
        func.date(UserDB.last_login) == today
    ).scalar() or 0
    
    # Construct additional data
    additional_data = {
        "new_users": new_users_today,
        "active_users": active_users_today,
        "total_users": total_users
    }
    
    # Create statistic
    stat_data = SystemStatisticsCreate(
        stat_type="user_growth",
        aggregate_value=total_users,
        user_count=new_users_today,
        date=today,
        additional_data=additional_data
    )
    
    return create_system_statistic(db_session, stat_data)

def calculate_ai_usage_statistics(db_session):
    """
    Calculate and store AI usage statistics
    
    Args:
        db_session: SQLAlchemy database session
        
    Returns:
        The created system statistic
    """
    today = date.today()
    
    # Get total AI interactions today
    total_interactions = db_session.query(func.count(AIInteractionDB.interaction_id)).filter(
        func.date(AIInteractionDB.created_at) == today
    ).scalar() or 0
    
    # Get successful AI interactions today
    successful_interactions = db_session.query(func.count(AIInteractionDB.interaction_id)).filter(
        func.date(AIInteractionDB.created_at) == today,
        AIInteractionDB.was_successful == True
    ).scalar() or 0
    
    # Get total tokens used today
    tokens_used = db_session.query(func.sum(AIInteractionDB.tokens_used)).filter(
        func.date(AIInteractionDB.created_at) == today
    ).scalar() or 0
    
    # Get average processing time
    avg_processing_time = db_session.query(func.avg(AIInteractionDB.processing_time)).filter(
        func.date(AIInteractionDB.created_at) == today
    ).scalar() or 0
    
    # Get unique users who used AI today
    unique_users = db_session.query(func.count(func.distinct(AIInteractionDB.user_id))).filter(
        func.date(AIInteractionDB.created_at) == today
    ).scalar() or 0
    
    # Construct AI metrics
    ai_usage_metrics = {
        "total_interactions": total_interactions,
        "successful_interactions": successful_interactions,
        "tokens_used": float(tokens_used) if tokens_used else 0,
        "average_processing_time": float(avg_processing_time) if avg_processing_time else 0,
        "success_rate": (successful_interactions / total_interactions * 100) if total_interactions else 0,
        "unique_users": unique_users
    }
    
    # Create statistic
    stat_data = SystemStatisticsCreate(
        stat_type="ai_usage",
        aggregate_value=float(tokens_used) if tokens_used else 0,
        user_count=unique_users,
        date=today,
        ai_usage_metrics=ai_usage_metrics
    )
    
    return create_system_statistic(db_session, stat_data)