from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime, date

# Schema for updating user statistics
class UserStatisticsUpdate(BaseModel):
    user_id: int  # ID of the user whose statistics are being updated
    date: date  # Date for the statistics entry
    tasks_completed: Optional[int] = 0  # Number of tasks completed by the user
    tasks_pending: Optional[int] = 0  # Number of pending tasks
    habits_streak: Optional[int] = 0  # Current streak of habits completed
    habits_completion_rate: Optional[float] = 0.00  # Completion rate (%) for habits
    productivity_score: Optional[int] = 0  # Productivity score (0-100)
    login_frequency: Optional[float] = 0.00  # Login frequency metric (e.g., logins per day)
    last_active_date: Optional[datetime] = None  # Last date the user was active
    ai_interaction_count: Optional[int] = 0  # Number of AI interactions the user has had
    ai_suggestion_adoption_rate: Optional[float] = 0.00  # Adoption rate (%) for AI suggestions

    # Validator for percentage fields (must be between 0 and 100)
    @validator('habits_completion_rate', 'ai_suggestion_adoption_rate')
    def validate_percentage(cls, v):
        if v is not None and (v < 0 or v > 100):
            raise ValueError('Percentage must be between 0 and 100')
        return v

    # Validator for count fields (must be non-negative)
    @validator('tasks_completed', 'tasks_pending', 'habits_streak', 'ai_interaction_count')
    def validate_counts(cls, v):
        if v is not None and v < 0:
            raise ValueError('Count values cannot be negative')
        return v

    # Validator for productivity score (must be between 0 and 100)
    @validator('productivity_score')
    def validate_productivity_score(cls, v):
        if v is not None and (v < 0 or v > 100):
            raise ValueError('Productivity score must be between 0 and 100')
        return v

# Schema for responding with user statistics
class UserStatisticsResponse(BaseModel):
    stat_id: int  # ID of the statistics entry
    user_id: int  # User ID associated with the statistics
    tasks_completed: int  # Number of tasks completed
    tasks_pending: int  # Number of pending tasks
    habits_streak: int  # Current habit streak
    habits_completion_rate: float  # Habit completion rate (%)
    productivity_score: int  # Productivity score (0-100)
    login_frequency: float  # Login frequency metric
    last_active_date: Optional[datetime] = None  # Last active date
    ai_interaction_count: int  # Number of AI interactions
    ai_suggestion_adoption_rate: float  # AI suggestion adoption rate (%)
    date: date  # Date of the statistics record

    model_config = {"from_attributes": True}  # Pydantic v2 config to allow ORM integration
