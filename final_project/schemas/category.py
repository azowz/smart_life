from pydantic import BaseModel, validator
from typing import Optional, List
from datetime import datetime, date, timedelta

# Pydantic model for creating categories
class CategoryCreate(BaseModel):
    name: str
    description: Optional[str] = None
    color: Optional[str] = None
    color_name: Optional[str] = None
    icon: Optional[str] = None
    location: Optional[str] = None
    repeat: Optional[str] = None
    station: Optional[str] = None
    remainder: Optional[date] = None
    progress_time: Optional[timedelta] = None
    progress_length: Optional[float] = None
    progress_weight: Optional[float] = None
    is_system: Optional[bool] = False
    created_by: Optional[int] = None
    parent_id: Optional[int] = None
    ai_recommended: Optional[bool] = False
    
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Name cannot be empty')
        if len(v) > 255:
            raise ValueError('Name must be 255 characters or less')
        return v.strip()
    
    @validator('color')
    def validate_color(cls, v):
        if v:
            # Simple hex color validation
            if not (v.startswith('#') and len(v) in [4, 7] and all(c in '0123456789ABCDEFabcdef' for c in v[1:])):
                raise ValueError('Color must be a valid hex color code (e.g., #4287f5)')
        return v
    
    @validator('progress_length', 'progress_weight')
    def validate_progress_values(cls, v):
        if v is not None and v < 0:
            raise ValueError('Progress values cannot be negative')
        return v

# Pydantic model for updating categories
class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    color: Optional[str] = None
    color_name: Optional[str] = None
    icon: Optional[str] = None
    location: Optional[str] = None
    repeat: Optional[str] = None
    station: Optional[str] = None
    remainder: Optional[date] = None
    progress_time: Optional[timedelta] = None
    progress_length: Optional[float] = None
    progress_weight: Optional[float] = None
    parent_id: Optional[int] = None
    
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if v is not None:
            if not v.strip():
                raise ValueError('Name cannot be empty')
            if len(v) > 255:
                raise ValueError('Name must be 255 characters or less')
            return v.strip()
        return v
    
    @validator('color')
    def validate_color(cls, v):
        if v:
            # Simple hex color validation
            if not (v.startswith('#') and len(v) in [4, 7] and all(c in '0123456789ABCDEFabcdef' for c in v[1:])):
                raise ValueError('Color must be a valid hex color code (e.g., #4287f5)')
        return v
    
    @validator('progress_length', 'progress_weight')
    def validate_progress_values(cls, v):
        if v is not None and v < 0:
            raise ValueError('Progress values cannot be negative')
        return v

# Pydantic model for responses
class CategoryResponse(BaseModel):
    category_id: int
    name: str
    description: Optional[str] = None
    color: Optional[str] = None
    color_name: Optional[str] = None
    icon: Optional[str] = None
    location: Optional[str] = None
    repeat: Optional[str] = None
    station: Optional[str] = None
    remainder: Optional[date] = None
    progress_time: Optional[timedelta] = None
    progress_length: Optional[float] = None
    progress_weight: Optional[float] = None
    is_system: bool
    created_by: Optional[int] = None
    parent_id: Optional[int] = None
    ai_recommended: bool
    created_at: datetime
    updated_at: datetime
    
    model_config = {
    "from_attributes": True  # هذا البديل في Pydantic v2
}

# Schema for nested category response
class CategoryNestedResponse(BaseModel):
    category: CategoryResponse
    subcategories: List['CategoryNestedResponse'] = []
    
    model_config = {
        "from_attributes": True  # Pydantic v2 equivalent of orm_mode
    }
# Add self-reference for nested response
CategoryNestedResponse.update_forward_refs()