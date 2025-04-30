from typing import List, Optional

from ..models.user_default_habit import UserDefaultHabitDB
from ..schemas.user_default_habit import UserDefaultHabitCreate, UserDefaultHabitUpdate
from ..services.default_habit import update_adoption_rate

def assign_default_habit(db_session, habit_data: UserDefaultHabitCreate):
    """
    Assign a default habit to a user
    
    Args:
        db_session: SQLAlchemy database session
        habit_data: User default habit data
        
    Returns:
        The created user default habit
    """
    # Check if the assignment already exists
    existing = db_session.query(UserDefaultHabitDB).filter(
        UserDefaultHabitDB.user_id == habit_data.user_id,
        UserDefaultHabitDB.default_habit_id == habit_data.default_habit_id
    ).first()
    
    if existing:
        # Update the existing assignment
        for key, value in habit_data.dict(exclude={"user_id", "default_habit_id"}).items():
            setattr(existing, key, value)
        db_session.commit()
        db_session.refresh(existing)
        return existing
    
    # Create new assignment
    db_user_habit = UserDefaultHabitDB(**habit_data.dict())
    db_session.add(db_user_habit)
    db_session.commit()
    db_session.refresh(db_user_habit)
    
    # Update adoption rate for this default habit
    update_adoption_rate(db_session, habit_data.default_habit_id)
    
    return db_user_habit

def update_user_default_habit(db_session, user_id: int, default_habit_id: int, habit_data: UserDefaultHabitUpdate):
    """
    Update a user's default habit assignment
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        default_habit_id: The default habit ID
        habit_data: Updated habit data
        
    Returns:
        The updated user default habit or None if not found
    """
    db_user_habit = db_session.query(UserDefaultHabitDB).filter(
        UserDefaultHabitDB.user_id == user_id,
        UserDefaultHabitDB.default_habit_id == default_habit_id
    ).first()
    
    if not db_user_habit:
        return None
    
    # Update only the fields that are provided
    update_data = habit_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_user_habit, key, value)
    
    db_session.commit()
    db_session.refresh(db_user_habit)
    
    # Update adoption rate for this default habit
    update_adoption_rate(db_session, default_habit_id)
    
    return db_user_habit

def get_user_default_habits(db_session, user_id: int, active_only: bool = False) -> List[UserDefaultHabitDB]:
    """
    Get all default habits assigned to a user
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        active_only: If True, return only active habits
        
    Returns:
        List of user default habits
    """
    query = db_session.query(UserDefaultHabitDB).filter(
        UserDefaultHabitDB.user_id == user_id
    )
    
    if active_only:
        query = query.filter(UserDefaultHabitDB.is_active == True)
    
    return query.all()

def get_user_default_habit(db_session, user_id: int, default_habit_id: int) -> Optional[UserDefaultHabitDB]:
    """
    Get a specific user default habit assignment
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        default_habit_id: The default habit ID
        
    Returns:
        The user default habit or None if not found
    """
    return db_session.query(UserDefaultHabitDB).filter(
        UserDefaultHabitDB.user_id == user_id,
        UserDefaultHabitDB.default_habit_id == default_habit_id
    ).first()

def get_default_habit_users(db_session, default_habit_id: int, active_only: bool = False) -> List[UserDefaultHabitDB]:
    """
    Get all users who have been assigned a specific default habit
    
    Args:
        db_session: SQLAlchemy database session
        default_habit_id: The default habit ID
        active_only: If True, return only active assignments
        
    Returns:
        List of user default habits
    """
    query = db_session.query(UserDefaultHabitDB).filter(
        UserDefaultHabitDB.default_habit_id == default_habit_id
    )
    
    if active_only:
        query = query.filter(UserDefaultHabitDB.is_active == True)
    
    return query.all()

def get_ai_recommended_habits(db_session, user_id: int, active_only: bool = False) -> List[UserDefaultHabitDB]:
    """
    Get all AI-recommended habits for a user
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        active_only: If True, return only active habits
        
    Returns:
        List of AI-recommended user default habits
    """
    query = db_session.query(UserDefaultHabitDB).filter(
        UserDefaultHabitDB.user_id == user_id,
        UserDefaultHabitDB.ai_recommended == True
    )
    
    if active_only:
        query = query.filter(UserDefaultHabitDB.is_active == True)
    
    return query.all()

def remove_default_habit(db_session, user_id: int, default_habit_id: int) -> bool:
    """
    Remove a default habit assignment for a user
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        default_habit_id: The default habit ID
        
    Returns:
        True if removed, False if not found
    """
    db_user_habit = db_session.query(UserDefaultHabitDB).filter(
        UserDefaultHabitDB.user_id == user_id,
        UserDefaultHabitDB.default_habit_id == default_habit_id
    ).first()
    
    if not db_user_habit:
        return False
    
    db_session.delete(db_user_habit)
    db_session.commit()
    
    # Update adoption rate for this default habit
    update_adoption_rate(db_session, default_habit_id)
    
    return True