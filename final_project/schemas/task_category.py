from pydantic import BaseModel, validator
from typing import Optional
from datetime import date

# Schema for creating a task category
class TaskCategoryCreate(BaseModel):
    user_id: int  # Link category to a user
    name: str  # Category name
    color: Optional[str] = "#4287f5"  # Optional color with default

    # Validator to ensure name is not empty
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v

# Schema for updating a task category
class TaskCategoryUpdate(BaseModel):
    name: Optional[str] = None  # Optional name update
    color: Optional[str] = None  # Optional color update

    # Validator for name (if provided)
    @validator('name')
    def name_cannot_be_empty(cls, v):
        if v is not None and not v.strip():
            raise ValueError('Name cannot be empty')
        return v

# Schema for responding with task category data
class TaskCategoryResponse(BaseModel):
    category_id: int  # Category ID
    user_id: int  # User ID
    name: str  # Category name
    color: Optional[str]  # Category color
    created_at: Optional[date]  # Creation date

    model_config = {
        "from_attributes": True  # Replaces orm_mode in Pydantic v2
    }