from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime
from enum import Enum

# ✅ Define enum for AI interaction types
class InteractionType(str, Enum):
    CHAT = "chat"                     # Chat conversation
    SUGGESTION = "suggestion"         # Task or habit suggestion
    ANALYSIS = "analysis"             # Data analysis interaction

# ✅ Pydantic model for creating AI interactions
class AIInteractionCreate(BaseModel):
    user_id: int                      # ID of the user initiating the interaction
    prompt: str                       # Prompt sent to the AI
    template_id: Optional[int] = None # Optional: template used for the prompt
    interaction_type: InteractionType # Type of interaction

    # ✅ Ensure prompt is not empty
    @validator('prompt')
    def prompt_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Prompt cannot be empty')
        return v.strip()

# ✅ Pydantic model for completing AI interactions (after response)
class AIInteractionComplete(BaseModel):
    response: Optional[str] = None          # AI-generated response
    processing_time: Optional[int] = None   # Time taken to process the interaction (ms)
    tokens_used: Optional[int] = None       # Tokens consumed during the interaction
    was_successful: bool = True             # Whether the interaction was successful

    # ✅ Validate processing time is non-negative
    @validator('processing_time')
    def validate_processing_time(cls, v):
        if v is not None and v < 0:
            raise ValueError('Processing time cannot be negative')
        return v

    # ✅ Validate tokens used is non-negative
    @validator('tokens_used')
    def validate_tokens_used(cls, v):
        if v is not None and v < 0:
            raise ValueError('Tokens used cannot be negative')
        return v

# ✅ Pydantic model for AI interaction response (retrieving data)
class AIInteractionResponse(BaseModel):
    interaction_id: int                  # Unique ID for the interaction
    user_id: int                         # ID of the user
    prompt: str                          # User's prompt
    response: Optional[str] = None       # AI's response
    template_id: Optional[int] = None    # Optional: template ID used
    interaction_type: str                # Type of interaction (string)
    created_at: datetime                 # Timestamp of creation
    processing_time: Optional[int] = None# Time taken to process (ms)
    tokens_used: Optional[int] = None    # Tokens consumed
    was_successful: bool                 # Whether successful

    # ✅ For Pydantic v2 ORM compatibility
    model_config = {"from_attributes": True}

# ✅ Pydantic model for AI interaction statistics
class AIInteractionStats(BaseModel):
    total_interactions: int             # Total number of interactions
    successful_interactions: int        # Number of successful interactions
    success_rate: float                 # Success rate percentage
    total_tokens: int                   # Total tokens consumed
    avg_processing_time: float          # Average processing time (ms)
    period_days: int                    # Period of analysis in days
    user_id: Optional[int] = None       # Optional: user-specific stats
