from typing import List, Optional
from datetime import datetime
from enum import Enum

from final_project.models.notification import NotificationDB
from final_project.schemas.notification import NotificationCreate, NotificationType

def create_notification(db_session, notification_data: NotificationCreate):
    """
    Create a new notification
    
    Args:
        db_session: SQLAlchemy database session
        notification_data: Notification data
        
    Returns:
        The created notification
    """
    # Convert Pydantic model to dict and handle Enum values
    notification_dict = notification_data.dict()
    if isinstance(notification_dict.get('notification_type'), Enum):
        notification_dict['notification_type'] = notification_dict['notification_type'].value
    
    db_notification = NotificationDB(**notification_dict)
    db_session.add(db_notification)
    db_session.commit()
    db_session.refresh(db_notification)
    return db_notification

def mark_notification_as_read(db_session, notification_id: int, user_id: int = None):
    """
    Mark a notification as read
    
    Args:
        db_session: SQLAlchemy database session
        notification_id: ID of the notification to mark
        user_id: Optional user ID to verify ownership
        
    Returns:
        The updated notification or None if not found or not owned by the user
    """
    query = db_session.query(NotificationDB).filter(
        NotificationDB.notification_id == notification_id
    )
    
    if user_id is not None:
        query = query.filter(NotificationDB.user_id == user_id)
    
    db_notification = query.first()
    
    if not db_notification:
        return None
    
    db_notification.is_read = True
    db_session.commit()
    db_session.refresh(db_notification)
    return db_notification

def mark_all_notifications_as_read(db_session, user_id: int):
    """
    Mark all notifications for a user as read
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        
    Returns:
        Number of notifications marked as read
    """
    result = db_session.query(NotificationDB).filter(
        NotificationDB.user_id == user_id,
        NotificationDB.is_read == False
    ).update({NotificationDB.is_read: True})
    
    db_session.commit()
    return result

def get_user_notifications(db_session, user_id: int, unread_only: bool = False, limit: int = 50, offset: int = 0) -> List[NotificationDB]:
    """
    Get notifications for a specific user
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        unread_only: If True, return only unread notifications
        limit: Maximum number of notifications to return
        offset: Number of notifications to skip
        
    Returns:
        List of notifications
    """
    query = db_session.query(NotificationDB).filter(
        NotificationDB.user_id == user_id
    )
    
    if unread_only:
        query = query.filter(NotificationDB.is_read == False)
    
    return query.order_by(
        NotificationDB.created_at.desc()
    ).limit(limit).offset(offset).all()

def delete_notification(db_session, notification_id: int, user_id: int = None) -> bool:
    """
    Delete a notification
    
    Args:
        db_session: SQLAlchemy database session
        notification_id: ID of the notification to delete
        user_id: Optional user ID to verify ownership
        
    Returns:
        True if deleted, False if not found or not owned by the user
    """
    query = db_session.query(NotificationDB).filter(
        NotificationDB.notification_id == notification_id
    )
    
    if user_id is not None:
        query = query.filter(NotificationDB.user_id == user_id)
    
    result = query.delete()
    db_session.commit()
    return result > 0

def create_task_reminder_notification(db_session, user_id: int, task_title: str, due_date: datetime):
    """
    Create a task reminder notification
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        task_title: The task title
        due_date: The task due date
        
    Returns:
        The created notification
    """
    notification_data = NotificationCreate(
        user_id=user_id,
        title="Task Reminder",
        message=f"Your task '{task_title}' is due {due_date.strftime('%Y-%m-%d %H:%M')}.",
        notification_type=NotificationType.TASK_REMINDER,
        ai_generated=False
    )
    
    return create_notification(db_session, notification_data)