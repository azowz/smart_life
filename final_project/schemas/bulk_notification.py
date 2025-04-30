from pydantic import BaseModel, validator
from typing import Optional, Dict, Any
from datetime import datetime

# ✅ Model for creating bulk notifications
class BulkNotificationCreate(BaseModel):
    title: str
    message: str
    created_by: int
    is_scheduled: bool = False
    schedule_time: Optional[datetime] = None
    target_criteria: Optional[Dict[str, Any]] = None

    @validator('title')
    def validate_title(cls, v):
        if len(v) > 255:
            raise ValueError('Title must be less than 255 characters')
        return v

    @validator('schedule_time')
    def validate_schedule_time(cls, v, values):
        # Ensure schedule_time is provided if is_scheduled is True
        if values.get('is_scheduled', False) and not v:
            raise ValueError('Schedule time is required when is_scheduled is True')
        return v

# ✅ Model for updating bulk notifications
class BulkNotificationUpdate(BaseModel):
    title: Optional[str] = None
    message: Optional[str] = None
    is_scheduled: Optional[bool] = None
    schedule_time: Optional[datetime] = None
    target_criteria: Optional[Dict[str, Any]] = None

    @validator('title')
    def validate_title(cls, v):
        if v and len(v) > 255:
            raise ValueError('Title must be less than 255 characters')
        return v

    @validator('schedule_time')
    def validate_schedule_time(cls, v, values):
        # Ensure schedule_time is provided if is_scheduled is True
        if values.get('is_scheduled') is True and not v:
            raise ValueError('Schedule time is required when is_scheduled is True')
        return v

# ✅ Model for response
class BulkNotificationResponse(BaseModel):
    bulk_notification_id: int
    title: str
    message: str
    created_by: int
    created_at: datetime
    sent_count: int
    is_scheduled: bool
    schedule_time: Optional[datetime] = None
    is_sent: bool
    target_criteria: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}  # ✅ متوافق مع Pydantic v2
