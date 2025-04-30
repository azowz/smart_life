from pydantic import BaseModel, validator
from typing import Optional
from datetime import date

# Schema for creating habit logs
class HabitLogCreate(BaseModel):
    habit_id: int                              # Reference to the related habit
    completed_date: Optional[date] = None      # The date when the habit was completed
    notes: Optional[str] = None                # Optional notes for the log
    value: Optional[float] = None              # Optional numeric value (e.g., time spent)

    @validator('value')
    def validate_value(cls, v):
        # Ensure value is non-negative if provided
        if v is not None and v < 0:
            raise ValueError('Value cannot be negative')
        return v

# Schema for updating habit logs
class HabitLogUpdate(BaseModel):
    completed_date: Optional[date] = None      # Allow updating the completed date
    notes: Optional[str] = None                # Allow updating the notes
    value: Optional[float] = None              # Allow updating the value

    @validator('value')
    def validate_value(cls, v):
        if v is not None and v < 0:
            raise ValueError('Value cannot be negative')
        return v

# Schema for responding with habit log data
class HabitLogResponse(BaseModel):
    log_id: int                                # Unique log identifier
    habit_id: int                              # Associated habit ID
    completed_date: date                       # Date when the habit was completed
    notes: Optional[str] = None                # Optional notes
    value: Optional[float] = None              # Optional value (e.g., time spent)

    model_config = {
        "from_attributes": True  # Pydantic v2 equivalent of orm_mode
    }
