from fastapi import APIRouter, Depends, HTTPException, Path, Body
from sqlalchemy.orm import Session
from typing import List

from final_project.db import get_db
from final_project.models.user import UserDB
from final_project.security import get_current_user
from final_project.schemas.configuration import (
    ConfigurationCreate, 
    ConfigurationUpdate, 
    ConfigurationResponse
)
from final_project.services.configuration import (
    create_configuration,
    update_configuration,
    get_configuration,
    get_all_configurations,
    get_active_configuration,
    delete_configuration
)

router = APIRouter(prefix="/configurations", tags=["configurations"])

@router.post("/", response_model=ConfigurationResponse, status_code=201)
def create_configuration_endpoint(
    config: ConfigurationCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Create a new configuration"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    return create_configuration(db=db, config_data=config)

@router.get("/", response_model=List[ConfigurationResponse])
def read_configurations(
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Get all configurations"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    return get_all_configurations(db=db)

@router.get("/active", response_model=ConfigurationResponse)
def read_active_configuration(
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Get the active configuration"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    config = get_active_configuration(db=db)
    if config is None:
        raise HTTPException(status_code=404, detail="No active configuration found")
    return config

@router.get("/{config_id}", response_model=ConfigurationResponse)
def read_configuration(
    config_id: int = Path(..., description="The configuration ID"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Get a specific configuration by ID"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    config = get_configuration(db=db, config_id=config_id)
    if config is None:
        raise HTTPException(status_code=404, detail="Configuration not found")
    return config

@router.put("/{config_id}", response_model=ConfigurationResponse)
def update_configuration_endpoint(
    config_id: int = Path(..., description="The configuration ID"),
    config: ConfigurationUpdate = Body(...),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Update a configuration"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    db_config = update_configuration(db=db, config_id=config_id, config_data=config)
    if db_config is None:
        raise HTTPException(status_code=404, detail="Configuration not found")
    return db_config

@router.delete("/{config_id}", status_code=204)
def delete_configuration_endpoint(
    config_id: int = Path(..., description="The configuration ID"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Delete a configuration"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    success = delete_configuration(db=db, config_id=config_id)
    if not success:
        raise HTTPException(
            status_code=404, 
            detail="Configuration not found or cannot delete active configuration"
        )
    return {"detail": "Configuration successfully deleted"}

@router.post("/{config_id}/activate", response_model=ConfigurationResponse)
def activate_configuration(
    config_id: int = Path(..., description="The configuration ID"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Activate a specific configuration"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    config_update = ConfigurationUpdate(is_active=True)
    db_config = update_configuration(db=db, config_id=config_id, config_data=config_update)
    if db_config is None:
        raise HTTPException(status_code=404, detail="Configuration not found")
    return db_config
