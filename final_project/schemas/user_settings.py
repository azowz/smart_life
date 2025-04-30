from pydantic import BaseModel, validator
from typing import Optional, Dict, Any
from enum import Enum

# Enum for theme options (Light, Dark, System)
class Theme(str, Enum):
    LIGHT = "light"
    DARK = "dark"
    SYSTEM = "system"

# Pydantic model for creating user settings
class UserSettingsCreate(BaseModel):
    user_id: int  # ID of the user these settings belong to
    theme: Optional[Theme] = Theme.SYSTEM  # UI theme preference (default: system)
    notification_preferences: Optional[Dict[str, Any]] = {}  # Notification preferences (can be customized)
    language: Optional[str] = "en"  # Preferred language (default: English)
    time_zone: Optional[str] = "UTC"  # Preferred time zone (default: UTC)
    ai_assistant_enabled: Optional[bool] = True  # Whether AI assistant is enabled (default: True)

    # Validator for language code (must be between 2 and 10 characters)
    @validator('language')
    def validate_language(cls, v):
        if v and (len(v) < 2 or len(v) > 10):
            raise ValueError('Language code should be between 2 and 10 characters')
        return v

    # Validator for time zone (must be a valid IANA time zone identifier)
    @validator('time_zone')
    def validate_time_zone(cls, v):
        valid_time_zones = [
            "UTC", "GMT", "America/New_York", "Europe/London", "Asia/Tokyo", 
            "Australia/Sydney", "Pacific/Auckland", "Africa/Cairo"
        ]
        if v and v not in valid_time_zones:
            raise ValueError('Invalid time zone. Please use a valid IANA time zone identifier')
        return v

# Pydantic model for responding with user settings
class UserSettingsResponse(BaseModel):
    settings_id: int  # ID of the settings record
    user_id: int  # User ID associated with these settings
    theme: str  # UI theme preference (light, dark, system)
    notification_preferences: Dict[str, Any]  # Notification preferences
    language: str  # Preferred language
    time_zone: str  # Preferred time zone
    ai_assistant_enabled: bool  # Whether AI assistant is enabled

    # Pydantic v2 configuration for ORM integration
    model_config = {"from_attributes": True}
