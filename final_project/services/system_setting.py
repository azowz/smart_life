from typing import List

from final_project.models.system_setting import SystemSettingDB
from final_project.schemas.system_setting import SystemSettingCreate

def create_or_update_system_setting(db_session, setting_data: SystemSettingCreate):
    """
    Create or update a system setting

    Args:
        db_session: SQLAlchemy database session
        setting_data: System setting data

    Returns:
        The created or updated system setting
    """
    # Check if setting already exists
    existing_setting = db_session.query(SystemSettingDB).filter(
        SystemSettingDB.key == setting_data.key
    ).first()

    if existing_setting:
        # Update existing setting
        for key, value in setting_data.dict(exclude={"key"}).items():
            if value is not None:  # Only update if value is provided
                setattr(existing_setting, key, value)
        db_session.commit()
        db_session.refresh(existing_setting)
        return existing_setting
    else:
        # Create new setting
        db_setting = SystemSettingDB(**setting_data.dict())
        db_session.add(db_setting)
        db_session.commit()
        db_session.refresh(db_setting)
        return db_setting

def get_system_setting(db_session, key: str):
    """
    Get a system setting by key

    Args:
        db_session: SQLAlchemy database session
        key: The setting key

    Returns:
        The system setting or None if not found
    """
    return db_session.query(SystemSettingDB).filter(
        SystemSettingDB.key == key
    ).first()

def get_system_setting_by_id(db_session, setting_id: int):
    """
    Get a system setting by ID
    
    Args:
        db_session: SQLAlchemy database session
        setting_id: The setting ID
        
    Returns:
        The system setting or None if not found
    """
    return db_session.query(SystemSettingDB).filter(
        SystemSettingDB.setting_id == setting_id
    ).first()

def get_ai_related_settings(db_session) -> List[SystemSettingDB]:
    """
    Get all AI-related system settings

    Args:
        db_session: SQLAlchemy database session

    Returns:
        List of AI-related system settings
    """
    return db_session.query(SystemSettingDB).filter(
        SystemSettingDB.ai_related == True
    ).all()

def get_all_system_settings(db_session) -> List[SystemSettingDB]:
    """
    Get all system settings
    
    Args:
        db_session: SQLAlchemy database session
        
    Returns:
        List of all system settings
    """
    return db_session.query(SystemSettingDB).order_by(
        SystemSettingDB.key
    ).all()

def delete_system_setting(db_session, key: str):
    """
    Delete a system setting by key
    
    Args:
        db_session: SQLAlchemy database session
        key: The setting key
        
    Returns:
        True if setting was deleted, False if not found
    """
    setting = db_session.query(SystemSettingDB).filter(
        SystemSettingDB.key == key
    ).first()
    
    if not setting:
        return False
    
    db_session.delete(setting)
    db_session.commit()
    return True