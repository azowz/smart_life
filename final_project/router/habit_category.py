from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from typing import List

from final_project.db import get_db
from final_project.schemas.category import CategoryResponse
# Assuming you'll create a HabitResponse schema
# from app.schemas.habit import HabitResponse
from final_project.services.habit_category import (
    add_category_to_habit,
    remove_category_from_habit,
    get_categories_for_habit,
    get_habits_by_category
)

router = APIRouter(tags=["habit-categories"])

@router.post("/habits/{habit_id}/categories/{category_id}", status_code=201)
def add_category_to_habit_endpoint(
    habit_id: int = Path(..., description="The habit ID"),
    category_id: int = Path(..., description="The category ID"),
    db: Session = Depends(get_db)
):
    """Associate a category with a habit"""
    result = add_category_to_habit(db=db, habit_id=habit_id, category_id=category_id)
    if result is False:
        return {"message": "Association already exists"}
    return {"message": "Category successfully added to habit"}

@router.delete("/habits/{habit_id}/categories/{category_id}", status_code=204)
def remove_category_from_habit_endpoint(
    habit_id: int = Path(..., description="The habit ID"),
    category_id: int = Path(..., description="The category ID"),
    db: Session = Depends(get_db)
):
    """Remove a category from a habit"""
    success = remove_category_from_habit(db=db, habit_id=habit_id, category_id=category_id)
    if not success:
        raise HTTPException(status_code=404, detail="Association not found")
    return {"message": "Category successfully removed from habit"}

@router.get("/habits/{habit_id}/categories", response_model=List[CategoryResponse])
def get_categories_for_habit_endpoint(
    habit_id: int = Path(..., description="The habit ID"),
    db: Session = Depends(get_db)
):
    """Get all categories associated with a habit"""
    return get_categories_for_habit(db=db, habit_id=habit_id)

# This endpoint is commented out as we don't have the HabitResponse schema defined yet
# @router.get("/categories/{category_id}/habits", response_model=List[HabitResponse])
# def get_habits_by_category_endpoint(
#     category_id: int = Path(..., description="The category ID"),
#     db: Session = Depends(get_db)
# ):
#     """Get all habits associated with a category"""
#     return get_habits_by_category(db=db, category_id=category_id)


from final_project.schemas.habit import HabitResponse

@router.get("/categories/{category_id}/habits", response_model=List[HabitResponse])
def get_habits_by_category_endpoint(
    category_id: int = Path(..., description="The category ID"),
    db: Session = Depends(get_db)
):
    """Get all habits associated with a category"""
    return get_habits_by_category(db=db, category_id=category_id)
