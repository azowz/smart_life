from pydantic import BaseModel, validator
from typing import Optional, Dict, Any
from datetime import datetime

# ✅ Schema for creating AI feedback
class AIFeedbackCreate(BaseModel):
    interaction_id: int                   # Interaction this feedback belongs to
    user_id: int                          # User providing the feedback
    rating: int                           # Feedback rating (1-5)
    feedback_text: Optional[str] = None   # Optional: feedback text
    
    @validator('rating')                  # ✅ Validate rating is between 1 and 5
    def validate_rating(cls, v):
        if v < 1 or v > 5:
            raise ValueError('Rating must be between 1 and 5')
        return v

# ✅ Schema for updating AI feedback
class AIFeedbackUpdate(BaseModel):
    rating: Optional[int] = None          # Optional: update rating
    feedback_text: Optional[str] = None   # Optional: update text
    is_used_for_improvement: Optional[bool] = None  # Optional: mark as used

    @validator('rating')                  # ✅ Validate rating if provided
    def validate_rating(cls, v):
        if v is not None and (v < 1 or v > 5):
            raise ValueError('Rating must be between 1 and 5')
        return v

# ✅ Schema for AI feedback response
class AIFeedbackResponse(BaseModel):
    feedback_id: int                      # Unique feedback ID
    interaction_id: int                   # Related interaction ID
    user_id: int                          # User ID
    rating: int                           # Rating value
    feedback_text: Optional[str] = None   # Feedback text
    created_at: datetime                  # Timestamp
    is_used_for_improvement: bool         # Whether used for improvement

    model_config = {"from_attributes": True}  # ✅ Compatible with Pydantic v2

# ✅ Schema for AI feedback statistics
class AIFeedbackStats(BaseModel):
    average_rating: float                 # Average rating across feedback
    rating_distribution: Dict[int, int]   # Count of ratings per value
    total_feedback_count: int             # Total number of feedback entries
    text_feedback_count: int              # Number of feedbacks with text
    text_feedback_percentage: float       # Percentage of feedbacks with text
