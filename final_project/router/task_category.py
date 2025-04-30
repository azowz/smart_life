from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from typing import List

from final_project.db import get_db
from final_project.schemas.category import CategoryResponse
from final_project.services.task_category import (
    add_category_to_task,
    remove_category_from_task,
    get_categories_for_task,
    get_tasks_by_category
)

router = APIRouter(prefix="/task-categories", tags=["task-categories"])

# Endpoint to associate a category with a task
@router.post("/tasks/{task_id}/categories/{category_id}", status_code=201)
def add_category_to_task_endpoint(
    task_id: int = Path(..., description="The task ID"),
    category_id: int = Path(..., description="The category ID"),
    db: Session = Depends(get_db)
):
    """Associate a category with a task"""
    result = add_category_to_task(db=db, task_id=task_id, category_id=category_id)
    if result is False:
        return {"message": "Association already exists"}
    return {"message": "Category successfully added to task"}

# Endpoint to remove a category from a task
@router.delete("/tasks/{task_id}/categories/{category_id}", status_code=204)
def remove_category_from_task_endpoint(
    task_id: int = Path(..., description="The task ID"),
    category_id: int = Path(..., description="The category ID"),
    db: Session = Depends(get_db)
):
    """Remove a category from a task"""
    success = remove_category_from_task(db=db, task_id=task_id, category_id=category_id)
    if not success:
        raise HTTPException(status_code=404, detail="Association not found")
    return {"message": "Category successfully removed from task"}

# Endpoint to get all categories associated with a task
@router.get("/tasks/{task_id}/categories", response_model=List[CategoryResponse])
def get_categories_for_task_endpoint(
    task_id: int = Path(..., description="The task ID"),
    db: Session = Depends(get_db)
):
    """Get all categories associated with a task"""
    return get_categories_for_task(db=db, task_id=task_id)

# Placeholder for getting tasks by category - requires TaskResponse schema
# @router.get("/categories/{category_id}/tasks", response_model=List[TaskResponse])
# def get_tasks_by_category_endpoint(
#     category_id: int = Path(..., description="The category ID"),
#     db: Session = Depends(get_db)
# ):
#     """Get all tasks associated with a category"""
#     return get_tasks_by_category(db=db, category_id=category_id)