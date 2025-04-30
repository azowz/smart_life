from pydantic import BaseModel, validator
from typing import Optional, List, Dict, Any
from datetime import date, time
from enum import Enum

# Enum for habit frequency
class HabitFrequency(str, Enum):
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"

# Schema for creating a habit
class HabitCreate(BaseModel):
    user_id: int
    name: str
    color: Optional[str] = "#4287f5"
    color_name: Optional[str] = None
    description: Optional[str] = None
    frequency: HabitFrequency = HabitFrequency.DAILY
    reminders: Optional[List[Dict[str, Any]]] = []
    time: Optional[time] = None
    start_date: Optional[date] = None
    target_count: Optional[int] = 1
    is_default_habit: Optional[bool] = False
    default_habit_id: Optional[int] = None
    ai_generated: Optional[bool] = False

    # Validate habit name
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Name cannot be empty')
        if len(v) > 100:
            raise ValueError('Name must be 100 characters or less')
        return v.strip()

    # Validate hex color code
    @validator('color')
    def validate_color(cls, v):
        if v and not (v.startswith('#') and len(v) in [4, 7] and all(c in '0123456789ABCDEFabcdef' for c in v[1:])):
            raise ValueError('Color must be a valid hex color code (e.g., #4287f5)')
        return v

    # Validate target count
    @validator('target_count')
    def validate_target_count(cls, v):
        if v is not None and v < 1:
            raise ValueError('Target count must be at least 1')
        return v

# Schema for updating a habit
class HabitUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None
    color_name: Optional[str] = None
    description: Optional[str] = None
    frequency: Optional[HabitFrequency] = None
    reminders: Optional[List[Dict[str, Any]]] = None
    time: Optional[time] = None
    target_count: Optional[int] = None

    @validator('name')
    def name_must_not_be_empty(cls, v):
        if v is not None:
            if not v.strip():
                raise ValueError('Name cannot be empty')
            if len(v) > 100:
                raise ValueError('Name must be 100 characters or less')
            return v.strip()
        return v

    @validator('color')
    def validate_color(cls, v):
        if v and not (v.startswith('#') and len(v) in [4, 7] and all(c in '0123456789ABCDEFabcdef' for c in v[1:])):
            raise ValueError('Color must be a valid hex color code (e.g., #4287f5)')
        return v

    @validator('target_count')
    def validate_target_count(cls, v):
        if v is not None and v < 1:
            raise ValueError('Target count must be at least 1')
        return v

# Schema for habit response
class HabitResponse(BaseModel):
    habit_id: int
    user_id: int
    name: str
    color: str
    color_name: Optional[str] = None
    description: Optional[str] = None
    frequency: str
    reminders: List[Dict[str, Any]]
    time: Optional[time] = None
    start_date: date
    target_count: int
    is_default_habit: bool
    default_habit_id: Optional[int] = None
    ai_generated: bool
    created_at: date

    model_config = {"from_attributes": True}  # Pydantic v2 compatible

# ----------------------------
# Habit Log schemas

# Schema for creating habit logs
class HabitLogCreate(BaseModel):
    habit_id: int
    completed_date: date
    count: Optional[int] = 1
    notes: Optional[str] = None

    @validator('count')
    def validate_count(cls, v):
        if v is not None and v < 1:
            raise ValueError('Count must be at least 1')
        return v

# Schema for updating habit logs
class HabitLogUpdate(BaseModel):
    count: Optional[int] = None
    notes: Optional[str] = None

    @validator('count')
    def validate_count(cls, v):
        if v is not None and v < 1:
            raise ValueError('Count must be at least 1')
        return v

# Schema for habit log response
class HabitLogResponse(BaseModel):
    log_id: int
    habit_id: int
    completed_date: date
    count: int
    notes: Optional[str] = None
    created_at: date

    model_config = {"from_attributes": True}  # Pydantic v2 compatible
