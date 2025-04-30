from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime
from enum import Enum

# ✅ Define enum for content types
class ContentType(str, Enum):
    HABIT_DESCRIPTION = "habit_description"
    TASK_EXAMPLE = "task_example"
    BEST_PRACTICE = "best_practice"

# ✅ Pydantic model for creating training texts
class AITrainingTextCreate(BaseModel):
    content: str                                     # The main text content
    content_type: ContentType                        # Type of the content (habit, task, practice)
    category_id: Optional[int] = None                # Related category (if any)
    description: Optional[str] = None                # Optional description for the text
    created_by: Optional[int] = None                 # Admin/user who created it
    is_active: Optional[bool] = True                 # Status of the training text
    effectiveness_rating: Optional[float] = None     # Rating of effectiveness (0-5)

    # ✅ Ensure content is not empty
    @validator('content')
    def content_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Content cannot be empty')
        return v.strip()

    # ✅ Ensure effectiveness rating is between 0 and 5
    @validator('effectiveness_rating')
    def validate_rating(cls, v):
        if v is not None and (v < 0 or v > 5):
            raise ValueError('Effectiveness rating must be between 0 and 5')
        return v

# ✅ Pydantic model for updating training texts
class AITrainingTextUpdate(BaseModel):
    content: Optional[str] = None
    content_type: Optional[ContentType] = None
    category_id: Optional[int] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None
    effectiveness_rating: Optional[float] = None

    # ✅ Ensure content is not empty if provided
    @validator('content')
    def content_must_not_be_empty(cls, v):
        if v is not None:
            if not v.strip():
                raise ValueError('Content cannot be empty')
            return v.strip()
        return v

    # ✅ Validate effectiveness rating
    @validator('effectiveness_rating')
    def validate_rating(cls, v):
        if v is not None and (v < 0 or v > 5):
            raise ValueError('Effectiveness rating must be between 0 and 5')
        return v

# ✅ Pydantic model for responses
class AITrainingTextResponse(BaseModel):
    text_id: int                                     # ID of the training text
    content: str                                     # The main text content
    content_type: str                                # Content type (habit/task/practice)
    category_id: Optional[int] = None                # Related category (if any)
    description: Optional[str] = None                # Description
    created_by: Optional[int] = None                 # Admin/user who created it
    created_at: datetime                             # Creation timestamp
    usage_count: int                                 # How many times this text was used
    effectiveness_rating: Optional[float] = None     # Effectiveness rating (0-5)
    is_active: bool                                  # Whether this training text is active

    # ✅ Configure for ORM compatibility in Pydantic v2
    model_config = {"from_attributes": True}
