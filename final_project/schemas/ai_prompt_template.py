from pydantic import BaseModel, validator
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum

# ✅ Define enum for prompt template purposes
class PromptTemplatePurpose(str, Enum):
    TASK_SUGGESTION = "task_suggestion"
    HABIT_RECOMMENDATION = "habit_recommendation"
    CHAT_RESPONSE = "chat_response"

# ✅ Pydantic model for creating prompt templates
class AIPromptTemplateCreate(BaseModel):
    name: str                                           # Template name
    purpose: PromptTemplatePurpose                      # Purpose of the template (task, habit, chat)
    template_text: str                                  # Actual prompt text
    parameters: Optional[Dict[str, Any]] = None         # Optional parameters for dynamic values
    created_by: Optional[int] = None                    # Creator's user/admin ID
    is_active: Optional[bool] = True                    # Whether this template is active

    # ✅ Validate name is not empty
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Name cannot be empty')
        if len(v) > 100:
            raise ValueError('Name must be 100 characters or less')
        return v.strip()

    # ✅ Validate template text is not empty
    @validator('template_text')
    def template_text_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Template text cannot be empty')
        return v.strip()

# ✅ Pydantic model for updating prompt templates
class AIPromptTemplateUpdate(BaseModel):
    name: Optional[str] = None                          # Template name (optional for updates)
    purpose: Optional[PromptTemplatePurpose] = None     # Template purpose (optional)
    template_text: Optional[str] = None                 # Prompt text (optional)
    parameters: Optional[Dict[str, Any]] = None         # Optional parameters
    is_active: Optional[bool] = None                    # Active status (optional)

    # ✅ Validate name if provided
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if v is not None:
            if not v.strip():
                raise ValueError('Name cannot be empty')
            if len(v) > 100:
                raise ValueError('Name must be 100 characters or less')
            return v.strip()
        return v

    # ✅ Validate template text if provided
    @validator('template_text')
    def template_text_must_not_be_empty(cls, v):
        if v is not None:
            if not v.strip():
                raise ValueError('Template text cannot be empty')
            return v.strip()
        return v

# ✅ Pydantic model for responses
class AIPromptTemplateResponse(BaseModel):
    template_id: int                                    # Unique ID for the template
    name: str                                           # Template name
    purpose: str                                        # Template purpose as a string
    template_text: str                                  # Prompt text
    parameters: Optional[Dict[str, Any]] = None         # Parameters used in the template
    created_by: Optional[int] = None                    # Creator's ID
    created_at: datetime                                # Creation timestamp
    last_updated: datetime                              # Last update timestamp
    is_active: bool                                     # Whether the template is active

    # ✅ ORM compatibility for Pydantic v2
    model_config = {"from_attributes": True}
