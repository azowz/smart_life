from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime

# Pydantic model for creating new configuration
class ConfigurationCreate(BaseModel):
    api_key: str
    model_version: str
    endpoint_url: str
    request_timeout: Optional[int] = 30
    max_tokens: Optional[int] = 2048
    temperature: Optional[float] = 0.7
    is_active: Optional[bool] = False
    updated_by: int
    
    @validator('request_timeout')
    def validate_timeout(cls, v):
        if v < 1:
            raise ValueError('Request timeout must be at least 1 second')
        return v
    
    @validator('max_tokens')
    def validate_max_tokens(cls, v):
        if v < 1:
            raise ValueError('Maximum tokens must be at least 1')
        return v
    
    @validator('temperature')
    def validate_temperature(cls, v):
        if v < 0 or v > 1:
            raise ValueError('Temperature must be between 0 and 1')
        return v

# Pydantic model for updating configuration
class ConfigurationUpdate(BaseModel):
    api_key: Optional[str] = None
    model_version: Optional[str] = None
    endpoint_url: Optional[str] = None
    request_timeout: Optional[int] = None
    max_tokens: Optional[int] = None
    temperature: Optional[float] = None
    is_active: Optional[bool] = None
    updated_by: Optional[int] = None
    
    @validator('request_timeout')
    def validate_timeout(cls, v):
        if v is not None and v < 1:
            raise ValueError('Request timeout must be at least 1 second')
        return v
    
    @validator('max_tokens')
    def validate_max_tokens(cls, v):
        if v is not None and v < 1:
            raise ValueError('Maximum tokens must be at least 1')
        return v
    
    @validator('temperature')
    def validate_temperature(cls, v):
        if v is not None and (v < 0 or v > 1):
            raise ValueError('Temperature must be between 0 and 1')
        return v

# Pydantic model for responses
class ConfigurationResponse(BaseModel):
    config_id: int
    api_key: str
    model_version: str
    endpoint_url: str
    request_timeout: int
    max_tokens: int
    temperature: float
    is_active: bool
    updated_by: Optional[int] = None
    updated_at: datetime
    
    
    model_config = {
        "from_attributes": True  # Replaces orm_mode in Pydantic v2
    }