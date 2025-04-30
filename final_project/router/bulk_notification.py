from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from final_project.services.bulk_notification import (
    create_bulk_notification,
    update_bulk_notification,
    get_bulk_notification,
    get_bulk_notifications,
    get_pending_scheduled_notifications,
    mark_notification_as_sent,
    delete_bulk_notification
)
from final_project.schemas.bulk_notification import BulkNotificationCreate, BulkNotificationUpdate, BulkNotificationResponse
from final_project.db import get_db
from final_project.security import get_current_user, UserDB  # 🔑 Import user dependencies

router = APIRouter(prefix="/bulk-notifications", tags=["Bulk Notifications"])

@router.post("/", response_model=BulkNotificationResponse)
def create_new_notification(
    notification_data: BulkNotificationCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)  # 🔑 Inject current user
):
    """
    Create a new bulk notification (superuser only)
    """
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    return create_bulk_notification(db, notification_data)

@router.get("/{notification_id}", response_model=BulkNotificationResponse)
def get_notification(
    notification_id: int = Path(..., description="The ID of the notification"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)  # 🔑 Restrict access
):
    """
    Get a bulk notification by ID (superuser only)
    """
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    notification = get_bulk_notification(db, notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Bulk notification not found")
    return notification

@router.get("/", response_model=List[BulkNotificationResponse])
def get_all_notifications(
    is_sent: Optional[bool] = Query(None, description="Filter by sent status"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)  # 🔑 Restrict access
):
    """
    Get all bulk notifications (superuser only)
    """
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    return get_bulk_notifications(db, created_by=current_user.user_id, is_sent=is_sent)

@router.put("/{notification_id}", response_model=BulkNotificationResponse)
def update_notification(
    notification_data: BulkNotificationUpdate,
    notification_id: int = Path(..., description="The ID of the notification to update"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)  # 🔑 Restrict access
):
    """
    Update an existing bulk notification (superuser only)
    """
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    existing_notification = get_bulk_notification(db, notification_id)
    if not existing_notification:
        raise HTTPException(status_code=404, detail="Bulk notification not found")
    if existing_notification.is_sent:
        raise HTTPException(status_code=400, detail="Cannot update a notification that has already been sent")

    return update_bulk_notification(db, notification_id, notification_data)

@router.get("/pending/now", response_model=List[BulkNotificationResponse])
def get_ready_notifications(
    db: Session = Depends(get_db)
):
    """
    Get all scheduled notifications that are ready to be sent
    """
    current_time = datetime.now()
    return get_pending_scheduled_notifications(db, current_time)

@router.post("/{notification_id}/mark-sent", response_model=BulkNotificationResponse)
def mark_as_sent(
    notification_id: int = Path(..., description="The ID of the notification to mark as sent"),
    sent_count: int = Query(..., description="Number of recipients the notification was sent to"),
    db: Session = Depends(get_db)
):
    """
    Mark a notification as sent and update the sent count
    """
    notification = mark_notification_as_sent(db, notification_id, sent_count)
    if not notification:
        raise HTTPException(status_code=404, detail="Bulk notification not found")
    return notification

@router.delete("/{notification_id}")
def delete_notification(
    notification_id: int = Path(..., description="The ID of the notification to delete"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)  # 🔑 Restrict access
):
    """
    Delete a bulk notification (only if not already sent) (superuser only)
    """
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")

    result = delete_bulk_notification(db, notification_id)
    if not result:
        raise HTTPException(status_code=404, detail="Bulk notification not found or already sent")
    
    return {"message": "Bulk notification deleted successfully"}
