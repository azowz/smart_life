from typing import Optional, Dict, Any, List
from datetime import datetime, timedelta
from enum import Enum
from sqlalchemy import func

from final_project.models.user_activity import UserActivityDB
from final_project.schemas.user_activity import UserActivityCreate, ActivityType, EntityType, ActivityStats

def log_user_activity(db_session, activity_data: UserActivityCreate):
    """
    Log a user activity
    
    Args:
        db_session: SQLAlchemy database session
        activity_data: Activity data
        
    Returns:
        The created activity log
    """
    # Convert Pydantic model to dict and handle Enum values
    activity_dict = activity_data.dict()
    if isinstance(activity_dict.get('activity_type'), Enum):
        activity_dict['activity_type'] = activity_dict['activity_type'].value
    if isinstance(activity_dict.get('entity_type'), Enum):
        activity_dict['entity_type'] = activity_dict['entity_type'].value
    
    db_activity = UserActivityDB(**activity_dict)
    db_session.add(db_activity)
    db_session.commit()
    db_session.refresh(db_activity)
    return db_activity

def get_user_activities(db_session, user_id: int, activity_type: Optional[str] = None, 
                        start_date: Optional[datetime] = None, end_date: Optional[datetime] = None, 
                        limit: int = 100, offset: int = 0) -> List[UserActivityDB]:
    """
    Get activities for a specific user with optional filtering
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        activity_type: Optional activity type filter
        start_date: Optional start date for filtering
        end_date: Optional end date for filtering
        limit: Maximum number of activities to return
        offset: Number of activities to skip
        
    Returns:
        List of user activities
    """
    query = db_session.query(UserActivityDB).filter(
        UserActivityDB.user_id == user_id
    )
    
    if activity_type:
        query = query.filter(UserActivityDB.activity_type == activity_type)
    
    if start_date:
        query = query.filter(UserActivityDB.created_at >= start_date)
    
    if end_date:
        query = query.filter(UserActivityDB.created_at <= end_date)
    
    return query.order_by(
        UserActivityDB.created_at.desc()
    ).limit(limit).offset(offset).all()

def get_entity_activity_history(db_session, entity_id: int, entity_type: str, limit: int = 50) -> List[UserActivityDB]:
    """
    Get activity history for a specific entity
    
    Args:
        db_session: SQLAlchemy database session
        entity_id: The entity ID
        entity_type: The entity type
        limit: Maximum number of activities to return
        
    Returns:
        List of activities related to the entity
    """
    return db_session.query(UserActivityDB).filter(
        UserActivityDB.entity_id == entity_id,
        UserActivityDB.entity_type == entity_type
    ).order_by(
        UserActivityDB.created_at.desc()
    ).limit(limit).all()

def get_activity_stats(db_session, user_id: Optional[int] = None, days: int = 30) -> ActivityStats:
    """
    Get statistics about user activities
    
    Args:
        db_session: SQLAlchemy database session
        user_id: Optional user ID to filter by
        days: Number of days to look back
        
    Returns:
        Dictionary with activity statistics
    """
    start_date = datetime.now() - timedelta(days=days)
    
    # Base query for activities in the time period
    query = db_session.query(
        UserActivityDB.activity_type,
        func.count().label('count')
    ).filter(
        UserActivityDB.created_at >= start_date
    )
    
    # Add user filter if provided
    if user_id:
        query = query.filter(UserActivityDB.user_id == user_id)
    
    # Group by activity type
    query = query.group_by(UserActivityDB.activity_type)
    
    # Execute query
    results = query.all()
    
    # Format results
    activity_counts = {activity_type.value: 0 for activity_type in ActivityType}
    for activity_type, count in results:
        activity_counts[activity_type] = count
    
    # Get total activities
    total_activities = sum(activity_counts.values())
    
    # Calculate AI interaction percentage
    ai_query = db_session.query(func.count()).filter(
        UserActivityDB.created_at >= start_date,
        UserActivityDB.ai_interaction == True
    )
    if user_id:
        ai_query = ai_query.filter(UserActivityDB.user_id == user_id)
    
    ai_interaction_count = ai_query.scalar() or 0
    ai_interaction_percentage = (ai_interaction_count / total_activities * 100) if total_activities else 0
    
    return ActivityStats(
        total_activities=total_activities,
        activity_breakdown=activity_counts,
        ai_interaction_count=ai_interaction_count,
        ai_interaction_percentage=round(ai_interaction_percentage, 2),
        period_days=days,
        user_id=user_id
    )

# Convenience functions for common activity types
def log_login_activity(db_session, user_id: int, device_info: Dict[str, Any] = None):
    """
    Log a user login activity
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        device_info: Optional device information
        
    Returns:
        The created activity log
    """
    activity_data = UserActivityCreate(
        user_id=user_id,
        activity_type=ActivityType.LOGIN,
        device_info=device_info
    )
    
    return log_user_activity(db_session, activity_data)

def log_task_completion(db_session, user_id: int, task_id: int):
    """
    Log a task completion activity
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        task_id: The task ID
        
    Returns:
        The created activity log
    """
    activity_data = UserActivityCreate(
        user_id=user_id,
        activity_type=ActivityType.TASK_COMPLETED,
        entity_id=task_id,
        entity_type=EntityType.TASK
    )
    
    return log_user_activity(db_session, activity_data)

def log_habit_completion(db_session, user_id: int, habit_id: int):
    """
    Log a habit completion activity
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        habit_id: The habit ID
        
    Returns:
        The created activity log
    """
    activity_data = UserActivityCreate(
        user_id=user_id,
        activity_type=ActivityType.HABIT_COMPLETED,
        entity_id=habit_id,
        entity_type=EntityType.HABIT
    )
    
    return log_user_activity(db_session, activity_data)

def log_ai_interaction(db_session, user_id: int, entity_id: Optional[int] = None, entity_type: Optional[EntityType] = None):
    """
    Log an AI interaction activity
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        entity_id: Optional related entity ID
        entity_type: Optional related entity type
        
    Returns:
        The created activity log
    """
    activity_data = UserActivityCreate(
        user_id=user_id,
        activity_type=ActivityType.AI_INTERACTION,
        entity_id=entity_id,
        entity_type=entity_type,
        ai_interaction=True
    )
    
    return log_user_activity(db_session, activity_data)