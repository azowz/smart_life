from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime

# Schema for creating a system setting
class SystemSettingCreate(BaseModel):
    key: str  # Setting key (identifier)
    value: Optional[str] = None  # Setting value
    description: Optional[str] = None  # Description of the setting
    ai_related: bool = False  # Indicates if the setting is related to AI features
    updated_by: Optional[int] = None  # ID of the user who updated the setting

    # Validator to ensure the key is not empty and within length limits
    @validator('key')
    def validate_key(cls, v):
        if not v or not v.strip():
            raise ValueError('Key cannot be empty')
        if len(v) > 100:
            raise ValueError('Key must be 100 characters or less')
        return v.strip()

# Schema for responding with a system setting
class SystemSettingResponse(BaseModel):
    setting_id: int  # Unique identifier for the setting
    key: str
    value: Optional[str] = None
    description: Optional[str] = None
    ai_related: bool
    updated_by: Optional[int] = None
    updated_at: datetime  # Timestamp of the last update

    # Pydantic v2 ORM compatibility
    model_config = {"from_attributes": True}
