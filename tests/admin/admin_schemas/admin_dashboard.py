from pydantic import BaseModel, validator
from typing import Optional, Dict, Any, List
from datetime import datetime


class WidgetPosition(BaseModel):
    x: int
    y: int
    w: int
    h: int

class DashboardWidget(BaseModel):
    type: str
    position: WidgetPosition
    title: Optional[str] = None
    settings: Optional[Dict[str, Any]] = None

class AdminDashboardCreate(BaseModel):
    admin_id: int
    name: str
    layout: Optional[Dict[str, Any]] = {}
    widgets: Optional[List[Dict[str, Any]]] = []
    is_default: Optional[bool] = False
    ai_insights_enabled: Optional[bool] = True
    
    @validator('name')
    def validate_name(cls, v):
        if not v or not v.strip():
            raise ValueError('Dashboard name cannot be empty')
        if len(v) > 100:
            raise ValueError('Dashboard name must be 100 characters or less')
        return v.strip()

class AdminDashboardUpdate(BaseModel):
    name: Optional[str] = None
    layout: Optional[Dict[str, Any]] = None
    widgets: Optional[List[Dict[str, Any]]] = None
    is_default: Optional[bool] = None
    ai_insights_enabled: Optional[bool] = None
    
    @validator('name')
    def validate_name(cls, v):
        if v is not None:
            if not v.strip():
                raise ValueError('Dashboard name cannot be empty')
            if len(v) > 100:
                raise ValueError('Dashboard name must be 100 characters or less')
            return v.strip()
        return v

class AdminDashboardResponse(BaseModel):
    dashboard_id: int
    admin_id: int
    name: str
    layout: Dict[str, Any]
    widgets: List[Dict[str, Any]]
    is_default: bool
    ai_insights_enabled: bool
    created_at: datetime
    updated_at: datetime
    
    model_config = {
        "from_attributes": True  # Replaces orm_mode in Pydantic v2
    }
class WidgetCreate(BaseModel):
    type: str
    position: WidgetPosition
    title: Optional[str] = None
    settings: Optional[Dict[str, Any]] = None
    
 