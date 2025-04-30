from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_db
from final_project.models.user import UserDB
from final_project.security import get_current_user
from final_project.schemas.category import (
    CategoryCreate, 
    CategoryUpdate, 
    CategoryResponse, 
    CategoryNestedResponse
)
from final_project.services.category import (
    create_category,
    update_category,
    get_category,
    get_categories,
    get_category_with_subcategories,
    delete_category
)

router = APIRouter(prefix="/categories", tags=["categories"])

@router.post("/", response_model=CategoryResponse, status_code=201)
def create_category_endpoint(
    category: CategoryCreate, 
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Create a new category (superuser only)"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    return create_category(db=db, category_data=category)

@router.get("/", response_model=List[CategoryResponse])
def read_categories(
    system_only: bool = Query(False, description="Filter for system categories only"),
    parent_id: Optional[int] = Query(None, description="Filter by parent category ID"),
    db: Session = Depends(get_db)
):
    """Get all categories, optionally filtered"""
    return get_categories(db=db, system_only=system_only, parent_id=parent_id)

@router.get("/{category_id}", response_model=CategoryResponse)
def read_category(
    category_id: int, 
    db: Session = Depends(get_db)
):
    """Get a specific category by ID"""
    db_category = get_category(db=db, category_id=category_id)
    if db_category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    return db_category

@router.get("/{category_id}/tree", response_model=CategoryNestedResponse)
def read_category_tree(
    category_id: int, 
    db: Session = Depends(get_db)
):
    """Get a category and all its subcategories in a tree structure"""
    result = get_category_with_subcategories(db=db, category_id=category_id)
    if result is None:
        raise HTTPException(status_code=404, detail="Category not found")
    return result

@router.put("/{category_id}", response_model=CategoryResponse)
def update_category_endpoint(
    category_id: int, 
    category: CategoryUpdate, 
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Update a category (superuser only)"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    db_category = update_category(db=db, category_id=category_id, category_data=category)
    if db_category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    return db_category

@router.delete("/{category_id}")
def delete_category_endpoint(
    category_id: int, 
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Delete a category (superuser only)"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    success = delete_category(db=db, category_id=category_id)
    if not success:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"detail": "Category successfully deleted"}
