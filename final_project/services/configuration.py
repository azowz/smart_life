from typing import List, Optional
from sqlalchemy.orm import Session

from final_project.models.configuration import ConfigurationDB
from final_project.schemas.configuration import ConfigurationCreate, ConfigurationUpdate

def get_active_configuration(db: Session):
    """
    Get the currently active configuration
    
    Args:
        db: SQLAlchemy database session
        
    Returns:
        The active configuration or None if not found
    """
    return db.query(ConfigurationDB).filter(
        ConfigurationDB.is_active == True
    ).first()

def update_configuration(db: Session, config_id: int, config_data: ConfigurationUpdate):
    """
    Update an existing configuration
    
    Args:
        db: SQLAlchemy database session
        config_id: ID of the configuration to update
        config_data: Configuration update data
        
    Returns:
        The updated configuration or None if not found
    """
    db_config = db.query(ConfigurationDB).filter(
        ConfigurationDB.config_id == config_id
    ).first()
    
    if not db_config:
        return None
    
    # Update only the fields that are provided
    update_data = config_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_config, key, value)
    
    # If setting this config as active, deactivate all others
    if update_data.get('is_active'):
        db.query(ConfigurationDB).filter(
            ConfigurationDB.config_id != config_id
        ).update({ConfigurationDB.is_active: False})
    
    db.commit()
    db.refresh(db_config)
    return db_config

def create_configuration(db: Session, config_data: ConfigurationCreate):
    """
    Create a new configuration
    
    Args:
        db: SQLAlchemy database session
        config_data: Configuration data
        
    Returns:
        The created configuration
    """
    # If setting as active, deactivate all others
    if config_data.is_active:
        db.query(ConfigurationDB).update({ConfigurationDB.is_active: False})
    
    db_config = ConfigurationDB(**config_data.dict())
    
    db.add(db_config)
    db.commit()
    db.refresh(db_config)
    return db_config

def get_all_configurations(db: Session):
    """
    Get all configurations
    
    Args:
        db: SQLAlchemy database session
        
    Returns:
        List of all configurations
    """
    return db.query(ConfigurationDB).order_by(
        ConfigurationDB.is_active.desc(),
        ConfigurationDB.updated_at.desc()
    ).all()

def get_configuration(db: Session, config_id: int):
    """
    Get a specific configuration by ID
    
    Args:
        db: SQLAlchemy database session
        config_id: The configuration ID
        
    Returns:
        The configuration or None if not found
    """
    return db.query(ConfigurationDB).filter(
        ConfigurationDB.config_id == config_id
    ).first()

def delete_configuration(db: Session, config_id: int):
    """
    Delete a configuration by ID
    
    Args:
        db: SQLAlchemy database session
        config_id: The configuration ID
        
    Returns:
        True if deleted successfully, False otherwise
    """
    db_config = db.query(ConfigurationDB).filter(
        ConfigurationDB.config_id == config_id
    ).first()
    
    if not db_config:
        return False
    
    # If this is the active configuration, don't allow deletion
    if db_config.is_active:
        return False
    
    db.delete(db_config)
    db.commit()
    return True