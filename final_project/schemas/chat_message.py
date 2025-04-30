from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime

# Pydantic model for creating chat messages
class ChatMessageCreate(BaseModel):
    user_id: int
    content: str
    is_ai_response: Optional[bool] = False
    related_entity_id: Optional[int] = None
    related_entity_type: Optional[str] = None
    
    @validator('content')
    def content_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Content cannot be empty')
        return v.strip()
    
    @validator('related_entity_type')
    def validate_entity_type(cls, v, values):
        if v is not None and values.get('related_entity_id') is None:
            raise ValueError('related_entity_id must be provided when related_entity_type is specified')
        
        if v is not None and len(v) > 50:
            raise ValueError('related_entity_type must be 50 characters or less')
        
        return v

# Pydantic model for updating chat messages
class ChatMessageUpdate(BaseModel):
    content: Optional[str] = None
    
    @validator('content')
    def content_must_not_be_empty(cls, v):
        if v is not None:
            if not v.strip():
                raise ValueError('Content cannot be empty')
            return v.strip()
        return v

# Pydantic model for responses
class ChatMessageResponse(BaseModel):
    message_id: int  # Message ID
    user_id: int  # User ID
    content: str  # Message content
    is_ai_response: bool  # AI response flag
    created_at: datetime  # Message creation timestamp
    related_entity_id: Optional[int] = None  # Related entity ID
    related_entity_type: Optional[str] = None  # Related entity type

    # Pydantic v2 config for ORM mode
    model_config = {
        "from_attributes": True  # Equivalent to orm_mode in Pydantic v1
    }
