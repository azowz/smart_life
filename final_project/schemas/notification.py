from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime
from enum import Enum

# Enum for different notification types
class NotificationType(str, Enum):
    TASK_REMINDER = "task_reminder"
    HABIT_REMINDER = "habit_reminder"
    SYSTEM_ALERT = "system_alert"
    ACHIEVEMENT = "achievement"
    AI_SUGGESTION = "ai_suggestion"

# Schema for creating a notification
class NotificationCreate(BaseModel):
    user_id: int  # ID of the user receiving the notification
    title: str  # Title of the notification
    message: str  # Notification message content
    notification_type: NotificationType  # Type of the notification
    ai_generated: Optional[bool] = False  # Indicates if AI generated the notification

    # Validator to ensure the title is not empty and within length limits
    @validator('title')
    def title_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Title cannot be empty')
        if len(v) > 255:
            raise ValueError('Title must be 255 characters or less')
        return v.strip()
    
    # Validator to ensure the message is not empty
    @validator('message')
    def message_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Message cannot be empty')
        return v.strip()

# Schema for updating a notification (e.g., marking it as read)
class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None  # Whether the notification has been read

# Schema for responding with notification data
class NotificationResponse(BaseModel):
    notification_id: int  # Unique identifier for the notification
    user_id: int
    title: str
    message: str
    is_read: bool
    notification_type: str
    ai_generated: bool
    created_at: datetime  # Timestamp when the notification was created

    # Pydantic v2 ORM compatibility
    model_config = {"from_attributes": True}
