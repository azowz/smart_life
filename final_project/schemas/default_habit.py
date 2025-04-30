from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


# Define an Enum for frequency
class FrequencyEnum(str, Enum):
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"


# Base schema shared by Create and Update
class DefaultHabitBase(BaseModel):
    name: Optional[str] = Field(None, description="Name of the default habit")
    description: Optional[str] = Field(None, description="Description of the habit")
    icon: Optional[str] = Field(None, description="Icon representing the habit")
    color: Optional[str] = Field(None, description="Color associated with the habit")
    frequency: Optional[FrequencyEnum] = Field(None, description="Frequency of the habit (daily, weekly, monthly)")
    category_id: Optional[int] = Field(None, description="ID of the associated category")
    effectiveness_score: Optional[float] = Field(None, description="Effectiveness score for AI ranking")
    ai_recommended: Optional[bool] = Field(None, description="Whether the habit is AI recommended")
    is_active: Optional[bool] = Field(default=True, description="Is the habit active?")


# Schema for creating a habit
class DefaultHabitCreate(DefaultHabitBase):
    created_by: Optional[int] = Field(None, description="ID of the superuser who created the habit")


# Schema for updating a habit
class DefaultHabitUpdate(DefaultHabitBase):
    pass  # Update can reuse the base


# Schema for responding with habit data
class DefaultHabitResponse(DefaultHabitBase):
    default_habit_id: int
    adoption_rate: Optional[float] = Field(0, description="Adoption rate percentage of this habit")

    class Config:
        orm_mode = True
