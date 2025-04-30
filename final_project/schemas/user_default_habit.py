from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# Pydantic model for creating a UserDefaultHabit (links a user to a default habit)
class UserDefaultHabitCreate(BaseModel):
    user_id: int  # The ID of the user
    default_habit_id: int  # The ID of the default habit
    is_active: Optional[bool] = True  # Whether the habit is active (default: True)

# Pydantic model for updating a UserDefaultHabit
class UserDefaultHabitUpdate(BaseModel):
    is_active: Optional[bool] = None  # Only the 'is_active' status can be updated

# Pydantic model for responding with UserDefaultHabit data
class UserDefaultHabitResponse(BaseModel):
    user_default_habit_id: int  # Unique ID for the user-default habit relation
    user_id: int  # The user ID
    default_habit_id: int  # The default habit ID
    is_active: bool  # Whether this habit is active
    created_at: datetime  # When the relation was created

    # Configuration for Pydantic v2 (ORM integration)
    model_config = {"from_attributes": True}

