from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.services.notification import (
    create_notification, 
    mark_notification_as_read,
    mark_all_notifications_as_read,
    get_user_notifications,
    delete_notification
)
from final_project.schemas.notification import NotificationCreate, NotificationResponse
from final_project.models.user import UserDB
from final_project.db import get_db

router = APIRouter(prefix="/notifications", tags=["Notifications"])

# 🔔 Create a new notification
@router.post("/", response_model=NotificationResponse)
def create_new_notification(
    notification_data: NotificationCreate,
    db: Session = Depends(get_db)
):
    """
    Create a new notification for a user.
    """
    # Verify user exists
    user = db.query(UserDB).filter(UserDB.user_id == notification_data.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return create_notification(db, notification_data)

# 🔔 Get notifications for a specific user
@router.get("/user/{user_id}", response_model=List[NotificationResponse])
def get_notifications_for_user(
    user_id: int = Path(..., description="The ID of the user"),
    unread_only: bool = Query(False, description="If true, return only unread notifications"),
    limit: int = Query(50, description="Maximum number of notifications to return"),
    offset: int = Query(0, description="Number of notifications to skip"),
    db: Session = Depends(get_db)
):
    """
    Retrieve notifications for a specific user.
    """
    # Verify user exists
    user = db.query(UserDB).filter(UserDB.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return get_user_notifications(db, user_id, unread_only, limit, offset)

# 🔔 Mark a specific notification as read
@router.put("/{notification_id}/read", response_model=NotificationResponse)
def mark_notification_read(
    notification_id: int = Path(..., description="The ID of the notification to mark as read"),
    user_id: Optional[int] = Query(None, description="Optional user ID for verification"),
    db: Session = Depends(get_db)
):
    """
    Mark a notification as read.
    """
    result = mark_notification_as_read(db, notification_id, user_id)
    if not result:
        raise HTTPException(status_code=404, detail="Notification not found or not owned by the user")
    
    return result

# 🔔 Mark all notifications for a user as read
@router.put("/user/{user_id}/read-all")
def mark_all_as_read(
    user_id: int = Path(..., description="The ID of the user"),
    db: Session = Depends(get_db)
):
    """
    Mark all notifications for a user as read.
    """
    # Verify user exists
    user = db.query(UserDB).filter(UserDB.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    count = mark_all_notifications_as_read(db, user_id)
    return {"message": f"Marked {count} notifications as read"}

# 🔔 Delete a specific notification
@router.delete("/{notification_id}")
def remove_notification(
    notification_id: int = Path(..., description="The ID of the notification to delete"),
    user_id: Optional[int] = Query(None, description="Optional user ID for verification"),
    db: Session = Depends(get_db)
):
    """
    Delete a notification.
    """
    result = delete_notification(db, notification_id, user_id)
    if not result:
        raise HTTPException(status_code=404, detail="Notification not found or not owned by the user")
    
    return {"message": "Notification deleted successfully"}
