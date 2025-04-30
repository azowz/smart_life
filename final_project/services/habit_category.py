from typing import List, Optional, Union
from sqlalchemy.orm import Session

from final_project.models.habit_category import HabitCategoryDB
from final_project.models.category import CategoryDB
# Assuming you have a HabitDB model
# from app.models.habit import HabitDB

def add_category_to_habit(db: Session, habit_id: int, category_id: int) -> Union[HabitCategoryDB, bool]:
    """
    Associate a category with a habit
    
    Args:
        db: SQLAlchemy database session
        habit_id: The habit ID
        category_id: The category ID
        
    Returns:
        The created association or False if it already exists
    """
    # Check if association already exists
    existing = db.query(HabitCategoryDB).filter(
        HabitCategoryDB.habit_id == habit_id,
        HabitCategoryDB.category_id == category_id
    ).first()
    
    if existing:
        return False
    
    # Create new association
    association = HabitCategoryDB(
        habit_id=habit_id,
        category_id=category_id
    )
    db.add(association)
    db.commit()
    return association

def remove_category_from_habit(db: Session, habit_id: int, category_id: int) -> bool:
    """
    Remove a category association from a habit
    #
    Args:
        db: SQLAlchemy database session
        habit_id: The habit ID
        category_id: The category ID
        
    Returns:
        True if removed, False if not found
    """
    result = db.query(HabitCategoryDB).filter(
        HabitCategoryDB.habit_id == habit_id,
        HabitCategoryDB.category_id == category_id
    ).delete()
    
    db.commit()
    return result > 0

def get_categories_for_habit(db: Session, habit_id: int) -> List[CategoryDB]:
    """
    Get all categories associated with a habit
    
    Args:
        db: SQLAlchemy database session
        habit_id: The habit ID
        
    Returns:
        List of categories
    """
    return db.query(CategoryDB).join(
        HabitCategoryDB,
        HabitCategoryDB.category_id == CategoryDB.category_id
    ).filter(
        HabitCategoryDB.habit_id == habit_id
    ).all()

def get_habits_by_category(db: Session, category_id: int):
    """
    Get all habits associated with a category
    
    Args:
        db: SQLAlchemy database session
        category_id: The category ID
        
    Returns:
        List of habits
    """
    # Assuming you have a HabitDB model
    # return db.query(HabitDB).join(
    #     HabitCategoryDB,
    #     HabitCategoryDB.habit_id == HabitDB.habit_id
    # ).filter(
    #     HabitCategoryDB.category_id == category_id
    # ).all()
    
    # This part is commented out as we don't have the HabitDB model defined yet
    # You can uncomment this once you have defined the HabitDB model
    pass