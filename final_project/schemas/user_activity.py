from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum

# Enum for the different types of user activities
class ActivityType(str, Enum):
    LOGIN = "login"
    LOGOUT = "logout"
    TASK_CREATED = "task_created"
    TASK_COMPLETED = "task_completed"
    HABIT_CREATED = "habit_created"
    HABIT_COMPLETED = "habit_completed"
    CATEGORY_CREATED = "category_created"
    SETTINGS_UPDATED = "settings_updated"
    AI_INTERACTION = "ai_interaction"

# Enum for different entity types associated with activities
class EntityType(str, Enum):
    TASK = "task"
    HABIT = "habit"
    CATEGORY = "category"
    SETTING = "setting"

# Model for creating user activity logs
class UserActivityCreate(BaseModel):
    user_id: int  # The ID of the user performing the activity
    activity_type: ActivityType  # The type of activity performed
    entity_id: Optional[int] = None  # The ID of the related entity (if any)
    entity_type: Optional[EntityType] = None  # The type of entity (if any)
    ai_interaction: Optional[bool] = False  # Whether this activity involved AI
    device_info: Optional[Dict[str, Any]] = None  # Optional device information

# Model for responding with user activity logs
class UserActivityResponse(BaseModel):
    activity_id: int  # Unique ID for the activity log
    user_id: int  # The user ID
    activity_type: str  # The activity type
    entity_id: Optional[int] = None  # Related entity ID (if any)
    entity_type: Optional[str] = None  # Related entity type (if any)
    ai_interaction: bool  # Whether the activity involved AI
    created_at: datetime  # Timestamp of when the activity was logged
    device_info: Optional[Dict[str, Any]] = None  # Optional device information

    # ✅ Pydantic v2 config for ORM integration
    model_config = {"from_attributes": True}

# Model for responding with activity statistics
class ActivityStats(BaseModel):
    total_activities: int  # Total number of activities
    activity_breakdown: Dict[str, int]  # Breakdown of activity types
    ai_interaction_count: int  # Number of AI-related interactions
    ai_interaction_percentage: float  # Percentage of AI interactions
    period_days: int  # The number of days considered for the stats
    user_id: Optional[int] = None  # Optional user ID for user-specific stats
