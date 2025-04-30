from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session

from final_project.models.category import CategoryDB
from final_project.schemas.category import CategoryCreate, CategoryUpdate, CategoryResponse, CategoryNestedResponse


def create_category(db: Session, category_data: CategoryCreate) -> CategoryDB:
    """
    Create a new category
    
    Args:
        db: SQLAlchemy database session
        category_data: Category data
        
    Returns:
        The created category
    """
    db_category = CategoryDB(**category_data.dict())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

def update_category(db: Session, category_id: int, category_data: CategoryUpdate) -> Optional[CategoryDB]:
    """
    Update an existing category
    
    Args:
        db: SQLAlchemy database session
        category_id: ID of the category to update
        category_data: Category update data
        
    Returns:
        The updated category or None if not found
    """
    db_category = db.query(CategoryDB).filter(CategoryDB.category_id == category_id).first()
    if not db_category:
        return None
    
    # Update only the fields that are provided
    update_data = category_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_category, key, value)
    
    db.commit()
    db.refresh(db_category)
    return db_category

def get_category(db: Session, category_id: int) -> Optional[CategoryDB]:
    """
    Get a category by ID
    
    Args:
        db: SQLAlchemy database session
        category_id: The category ID
        
    Returns:
        The category or None if not found
    """
    return db.query(CategoryDB).filter(CategoryDB.category_id == category_id).first()

def get_categories(
    db: Session, 
    system_only: bool = False, 
    parent_id: Optional[int] = None
) -> List[CategoryDB]:
    """
    Get categories, optionally filtered by system status or parent
    
    Args:
        db: SQLAlchemy database session
        system_only: If True, return only system categories
        parent_id: Optional parent ID to filter subcategories
        
    Returns:
        List of categories
    """
    query = db.query(CategoryDB)
    
    if system_only:
        query = query.filter(CategoryDB.is_system == True)
    
    if parent_id is not None:
        query = query.filter(CategoryDB.parent_id == parent_id)
    
    return query.order_by(CategoryDB.name).all()

def get_category_with_subcategories(db: Session, category_id: int) -> Optional[Dict[str, Any]]:
    """
    Get a category along with all its subcategories
    
    Args:
        db: SQLAlchemy database session
        category_id: The category ID
        
    Returns:
        Dictionary with category and subcategories
    """
    category = db.query(CategoryDB).filter(CategoryDB.category_id == category_id).first()
    if not category:
        return None
    
    # Build a recursive function to get all subcategories
    def get_subcategories(category_id):
        subcategories = db.query(CategoryDB).filter(CategoryDB.parent_id == category_id).all()
        result = []
        for subcat in subcategories:
            sub_item = {
                "category": subcat,
                "subcategories": get_subcategories(subcat.category_id)
            }
            result.append(sub_item)
        return result
    
    return {
        "category": category,
        "subcategories": get_subcategories(category.category_id)
    }

def delete_category(db: Session, category_id: int) -> bool:
    """
    Delete a category by ID
    
    Args:
        db: SQLAlchemy database session
        category_id: The category ID
        
    Returns:
        True if deleted successfully, False otherwise
    """
    db_category = db.query(CategoryDB).filter(CategoryDB.category_id == category_id).first()
    if not db_category:
        return False
    
    db.delete(db_category)
    db.commit()
    return True