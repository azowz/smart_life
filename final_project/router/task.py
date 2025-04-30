from fastapi import APIRouter, Depends, HTTPException, Path, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_session
from final_project.models.user import UserDB  # Import UserDB directly
from final_project.models.task import TaskDB
from final_project.schemas.task import TaskCreate, TaskResponse, TaskUpdate
from final_project.security import get_current_user  # Remove User from this import

router = APIRouter(prefix="/tasks", tags=["tasks"])

# Get all tasks for current user
@router.get("/", response_model=List[TaskResponse])
async def list_tasks(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=1000),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    tasks = session.query(TaskDB).filter(
        TaskDB.created_by_user_id == current_user.user_id
    ).offset(skip).limit(limit).all()
    return tasks

# Create a new task
@router.post("/", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
async def create_task(
    task: TaskCreate,
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_task = TaskDB(
        title=task.title,
        description=task.description,
        created_by_user_id=current_user.user_id,
        is_completed=task.is_completed
    )
    session.add(db_task)
    session.commit()
    session.refresh(db_task)
    return db_task

# Get task by ID
@router.get("/{task_id}", response_model=TaskResponse)
async def read_task(
    task_id: int = Path(..., gt=0),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    task = session.query(TaskDB).filter(
        TaskDB.task_id == task_id,
        TaskDB.created_by_user_id == current_user.user_id
    ).first()
    
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return task

# Update task
@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(
    task_id: int = Path(..., gt=0),
    task_update: TaskUpdate = ...,
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_task = session.query(TaskDB).filter(
        TaskDB.task_id == task_id,
        TaskDB.created_by_user_id == current_user.user_id
    ).first()
    
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Update task fields
    update_data = task_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_task, key, value)
    
    session.commit()
    session.refresh(db_task)
    return db_task

# Delete task
@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(
    task_id: int = Path(..., gt=0),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_task = session.query(TaskDB).filter(
        TaskDB.task_id == task_id,
        TaskDB.created_by_user_id == current_user.user_id
    ).first()
    
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    session.delete(db_task)
    session.commit()
    return None

# Toggle task completion status
@router.patch("/{task_id}/toggle", response_model=TaskResponse)
async def toggle_task_completion(
    task_id: int = Path(..., gt=0),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_task = session.query(TaskDB).filter(
        TaskDB.task_id == task_id,
        TaskDB.created_by_user_id == current_user.user_id
    ).first()
    
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Toggle completion status
    db_task.is_completed = not db_task.is_completed
    
    session.commit()
    session.refresh(db_task)
    return db_task