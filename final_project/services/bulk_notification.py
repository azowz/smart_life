from typing import List, Optional
from datetime import datetime

from final_project.models.bulk_notification import BulkNotificationDB
from final_project.schemas.bulk_notification import BulkNotificationCreate, BulkNotificationUpdate

def create_bulk_notification(db_session, notification_data: BulkNotificationCreate):
    """
    Create a new bulk notification
    
    Args:
        db_session: SQLAlchemy database session
        notification_data: Bulk notification data
        
    Returns:
        The created bulk notification
    """
    db_notification = BulkNotificationDB(**notification_data.dict())
    db_session.add(db_notification)
    db_session.commit()
    db_session.refresh(db_notification)
    return db_notification

def update_bulk_notification(db_session, notification_id: int, notification_data: BulkNotificationUpdate):
    """
    Update an existing bulk notification
    
    Args:
        db_session: SQLAlchemy database session
        notification_id: ID of the notification to update
        notification_data: Updated notification data
        
    Returns:
        The updated bulk notification or None if not found
    """
    notification = db_session.query(BulkNotificationDB).filter(
        BulkNotificationDB.bulk_notification_id == notification_id
    ).first()
    
    if not notification:
        return None
    
    # Only update fields that are provided
    for key, value in notification_data.dict(exclude_unset=True).items():
        setattr(notification, key, value)
    
    db_session.commit()
    db_session.refresh(notification)
    return notification

def get_bulk_notification(db_session, notification_id: int):
    """
    Get a bulk notification by ID
    
    Args:
        db_session: SQLAlchemy database session
        notification_id: ID of the notification to retrieve
        
    Returns:
        The bulk notification or None if not found
    """
    return db_session.query(BulkNotificationDB).filter(
        BulkNotificationDB.bulk_notification_id == notification_id
    ).first()

def get_bulk_notifications(db_session, created_by: Optional[int] = None, is_sent: Optional[bool] = None) -> List[BulkNotificationDB]:
    """
    Get all bulk notifications with optional filtering
    
    Args:
        db_session: SQLAlchemy database session
        created_by: Optional filter by admin ID who created the notification
        is_sent: Optional filter by sent status
        
    Returns:
        List of bulk notifications
    """
    query = db_session.query(BulkNotificationDB)
    
    if created_by is not None:
        query = query.filter(BulkNotificationDB.created_by == created_by)
    
    if is_sent is not None:
        query = query.filter(BulkNotificationDB.is_sent == is_sent)
    
    return query.order_by(BulkNotificationDB.created_at.desc()).all()

def get_pending_scheduled_notifications(db_session, current_time: datetime) -> List[BulkNotificationDB]:
    """
    Get all scheduled notifications that are ready to be sent
    
    Args:
        db_session: SQLAlchemy database session
        current_time: Current time to check against schedule_time
        
    Returns:
        List of notifications ready to be sent
    """
    return db_session.query(BulkNotificationDB).filter(
        BulkNotificationDB.is_scheduled == True,
        BulkNotificationDB.is_sent == False,
        BulkNotificationDB.schedule_time <= current_time
    ).all()

def mark_notification_as_sent(db_session, notification_id: int, sent_count: int):
    """
    Mark a notification as sent and update the sent count
    
    Args:
        db_session: SQLAlchemy database session
        notification_id: ID of the notification to mark as sent
        sent_count: Number of recipients the notification was sent to
        
    Returns:
        The updated notification or None if not found
    """
    notification = db_session.query(BulkNotificationDB).filter(
        BulkNotificationDB.bulk_notification_id == notification_id
    ).first()
    
    if not notification:
        return None
    
    notification.is_sent = True
    notification.sent_count = sent_count
    
    db_session.commit()
    db_session.refresh(notification)
    return notification

def delete_bulk_notification(db_session, notification_id: int):
    """
    Delete a bulk notification
    
    Args:
        db_session: SQLAlchemy database session
        notification_id: ID of the notification to delete
        
    Returns:
        True if deleted, False if not found
    """
    notification = db_session.query(BulkNotificationDB).filter(
        BulkNotificationDB.bulk_notification_id == notification_id
    ).first()
    
    if not notification:
        return False
    
    # Don't allow deleting already sent notifications
    if notification.is_sent:
        return False
    
    db_session.delete(notification)
    db_session.commit()
    return True