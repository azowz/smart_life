from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime
from enum import Enum

# ✅ Enum for types of AI interactions
class InteractionType(str, Enum):
    CHAT = "chat"           # AI chat conversation
    SUGGESTION = "suggestion"   # Task or habit suggestion
    ANALYSIS = "analysis"       # Analytical or data-driven request

# ✅ Request body schema for creating a new AI interaction
class AIInteractionCreate(BaseModel):
    user_id: int                         # User initiating the interaction
    prompt: str                          # Initial message to the AI
    template_id: Optional[int] = None    # Optional template association
    interaction_type: InteractionType    # Enum value specifying interaction purpose

    @validator('prompt')
    def prompt_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Prompt cannot be empty')
        return v.strip()

# ✅ Request body schema for completing an AI interaction
class AIInteractionComplete(BaseModel):
    user_message: str                           # Required: original message from user (used in fallback)
    processing_time: Optional[int] = None       # How long the AI took to respond (in ms)
    tokens_used: Optional[int] = None           # Number of tokens used
    was_successful: bool = True                 # Indicates success/failure of interaction

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

# ✅ Response model for returning a full AI interaction
class AIInteractionResponse(BaseModel):
    interaction_id: int                    # Unique identifier
    user_id: int                           # Owner user
    prompt: str                            # Original user prompt
    response: Optional[str] = None         # AI-generated response
    template_id: Optional[int] = None      # Linked template if any
    interaction_type: str                  # Type of interaction (chat, suggestion, ...)
    created_at: datetime                   # Timestamp of interaction
    processing_time: Optional[int] = None  # Time taken in milliseconds
    tokens_used: Optional[int] = None      # Tokens used
    was_successful: bool                   # Whether it completed without failure

    # Pydantic V2 configuration to support ORM model conversion
    model_config = {"from_attributes": True}

# ✅ Aggregated statistics response model
class AIInteractionStats(BaseModel):
    total_interactions: int               # Total count
    successful_interactions: int          # Number of successful ones
    success_rate: float                   # % of success
    total_tokens: int                     # All tokens consumed
    avg_processing_time: float            # Mean response time
    period_days: int                      # Period this stat was computed over
    user_id: Optional[int] = None         # Optional: Filtered by user (if requested)
