from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime
from enum import Enum

# Enum for interaction types
class InteractionType(str, Enum):
    CHAT = "chat"
    SUGGESTION = "suggestion"
    ANALYSIS = "analysis"

# Schema for creating an interaction
class AIInteractionCreate(BaseModel):
    user_id: int
    prompt: str
    template_id: Optional[int] = None
    interaction_type: InteractionType

    @validator('prompt')
    def prompt_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Prompt cannot be empty')
        return v.strip()

# Schema for completing an interaction
class AIInteractionComplete(BaseModel):
    user_message: str
    processing_time: Optional[int] = None
    tokens_used: Optional[int] = None
    was_successful: bool = True

    @validator('processing_time')
    def validate_processing_time(cls, v):
        if v is not None and v < 0:
            raise ValueError('Processing time cannot be negative')
        return v

    @validator('tokens_used')
    def validate_tokens_used(cls, v):
        if v is not None and v < 0:
            raise ValueError('Tokens used cannot be negative')
        return v

# Schema for returning an interaction
class AIInteractionResponse(BaseModel):
    interaction_id: int
    user_id: int
    prompt: str
    response: Optional[str] = None
    template_id: Optional[int] = None
    interaction_type: str
    created_at: datetime
    processing_time: Optional[int] = None
    tokens_used: Optional[int] = None
    was_successful: bool

    model_config = {"from_attributes": True}  # For SQLAlchemy integration

# Schema for stats
class AIInteractionStats(BaseModel):
    total_interactions: int
    successful_interactions: int
    success_rate: float
    total_tokens: int
    avg_processing_time: float
    period_days: int
    user_id: Optional[int] = None
