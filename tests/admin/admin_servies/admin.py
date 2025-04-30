from datetime import datetime
from typing import List, Optional
from sqlalchemy.orm import Session
from final_project.models.admin.admin import AdminDB
from final_project.schemas.admin_schemas.admin import AdminCreate, AdminUpdate, AdminPasswordChange
from final_project.security import get_password_hash, verify_password

def create_admin(db: Session, admin_data: AdminCreate) -> AdminDB:
    """
    Create a new admin

    Args:
        db: SQLAlchemy database session
        admin_data: Admin data
        
    Returns:
        The created admin
    """
    # Hash the password
    hashed_password = get_password_hash(admin_data.password)
    
    # Create an admin dict without the password
    admin_dict = admin_data.dict(exclude={"password"})
    admin_dict["password_hash"] = hashed_password
    
    # Create the admin
    db_admin = AdminDB(**admin_dict)
    db.add(db_admin)
    db.commit()
    db.refresh(db_admin)
    return db_admin

def update_admin(db: Session, admin_id: int, admin_data: AdminUpdate) -> Optional[AdminDB]:
    """
    Update an existing admin

    Args:
        db: SQLAlchemy database session
        admin_id: The admin ID
        admin_data: Admin update data

    Returns:
        The updated admin or None if not found
    """
    db_admin = db.query(AdminDB).filter(AdminDB.admin_id == admin_id).first()
    if not db_admin:
        return None
    
    # Update only the fields that are provided
    update_data = admin_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_admin, key, value)
    
    db.commit()
    db.refresh(db_admin)
    return db_admin

def change_admin_password(db: Session, admin_id: int, password_data: AdminPasswordChange) -> Optional[AdminDB]:
    """
    Change an admin's password

    Args:
        db: SQLAlchemy database session
        admin_id: The admin ID
        password_data: Password change data containing current and new passwords
        
    Returns:
        The updated admin or None if not found or current password is wrong
    """
    db_admin = db.query(AdminDB).filter(AdminDB.admin_id == admin_id).first()
    if not db_admin:
        return None
    
    # Verify current password
    if not verify_password(password_data.current_password, db_admin.password_hash):
        return None
    
    # Update password
    db_admin.password_hash = get_password_hash(password_data.new_password)
    db.commit()
    db.refresh(db_admin)
    return db_admin

def get_admin(db: Session, admin_id: int) -> Optional[AdminDB]:
    """
    Get an admin by ID

    Args:
        db: SQLAlchemy database session
        admin_id: The admin ID
        
    Returns:
        The admin or None if not found
    """
    return db.query(AdminDB).filter(AdminDB.admin_id == admin_id).first()

def get_admin_by_username(db: Session, username: str) -> Optional[AdminDB]:
    """
    Get an admin by username

    Args:
        db: SQLAlchemy database session
        username: The admin username
        
    Returns:
        The admin or None if not found
    """
    return db.query(AdminDB).filter(AdminDB.username == username).first()

def get_admin_by_email(db: Session, email: str) -> Optional[AdminDB]:
    """
    Get an admin by email

    Args:
        db: SQLAlchemy database session
        email: The admin email
        
    Returns:
        The admin or None if not found
    """
    return db.query(AdminDB).filter(AdminDB.email == email).first()

def get_all_admins(db: Session, skip: int = 0, limit: int = 100) -> List[AdminDB]:
    """
    Get all admins

    Args:
        db: SQLAlchemy database session
        skip: Number of records to skip
        limit: Maximum number of records to return
        
    Returns:
        List of admins
    """
    return db.query(AdminDB).offset(skip).limit(limit).all()

def delete_admin(db: Session, admin_id: int) -> bool:
    """
    Delete an admin

    Args:
        db: SQLAlchemy database session
        admin_id: The admin ID
        
    Returns:
        True if deleted successfully, False otherwise
    """
    db_admin = db.query(AdminDB).filter(AdminDB.admin_id == admin_id).first()
    if not db_admin:
        return False
    
    db.delete(db_admin)
    db.commit()
    return True

def authenticate_admin(db: Session, username: str, password: str) -> Optional[AdminDB]:
    """
    Authenticate an admin with username and password

    Args:
        db: SQLAlchemy database session
        username: The admin username
        password: The plain password
        
    Returns:
        The admin if authentication is successful, None otherwise
    """
    db_admin = get_admin_by_username(db, username)
    if not db_admin:
        return None
    
    if not verify_password(password, db_admin.password_hash):
        return None
    
    # Update last login time
    db_admin.last_login = datetime.utcnow()
    db.commit()
    
    return db_admin

def update_admin_activity(db: Session, admin_id: int, is_active: bool) -> Optional[AdminDB]:
    """
    Update an admin's active status

    Args:
        db: SQLAlchemy database session
        admin_id: The admin ID
        is_active: New active status
        
    Returns:
        The updated admin or None if not found
    """
    db_admin = db.query(AdminDB).filter(AdminDB.admin_id == admin_id).first()
    if not db_admin:
        return None
    
    db_admin.is_active = is_active
    db.commit()
    db.refresh(db_admin)
    return db_admin
