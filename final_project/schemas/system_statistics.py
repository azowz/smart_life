from pydantic import BaseModel, validator
from typing import Optional, Dict, Any
from datetime import datetime, date

# Pydantic schema for creating system statistics
class SystemStatisticsCreate(BaseModel):
    stat_type: str  # Type of the statistic (e.g., 'user_growth', 'ai_usage')
    aggregate_value: Optional[float] = None  # Aggregate value like average or total
    user_count: Optional[int] = None  # Count of users involved
    date: date  # Date of the statistic
    additional_data: Optional[Dict[str, Any]] = None  # Any extra data
    ai_usage_metrics: Optional[Dict[str, Any]] = None  # AI usage-related metrics

    # Validator to ensure stat_type is valid
    @validator('stat_type')
    def validate_stat_type(cls, v):
        if not v or not v.strip():
            raise ValueError('Statistic type cannot be empty')
        if len(v) > 50:
            raise ValueError('Statistic type must be 50 characters or less')
        return v.strip()

# Pydantic schema for responding with system statistics
class SystemStatisticsResponse(BaseModel):
    stat_id: int  # ID of the statistic entry
    stat_type: str  # Type of the statistic
    aggregate_value: Optional[float] = None
    user_count: Optional[int] = None
    date: date
    additional_data: Optional[Dict[str, Any]] = None
    ai_usage_metrics: Optional[Dict[str, Any]] = None
    created_at: datetime  # Timestamp when the entry was created

    # Use from_attributes for Pydantic v2 ORM compatibility
    model_config = {"from_attributes": True}
