from typing import List, Optional, Union
from sqlalchemy.orm import Session

from final_project.models.task_category import TaskCategoryDB
from final_project.models.category import CategoryDB
from final_project.models.task import TaskDB  # ✅ Ensure this model exists


def add_category_to_task(db: Session, task_id: int, category_id: int) -> Union[TaskCategoryDB, bool]:
    """
    Associate a category with a task.

    Args:
        db: SQLAlchemy database session
        task_id: The task ID
        category_id: The category ID

    Returns:
        The created association or False if it already exists
    """
    existing = db.query(TaskCategoryDB).filter(
        TaskCategoryDB.task_id == task_id,
        TaskCategoryDB.category_id == category_id
    ).first()

    if existing:
        return False

    association = TaskCategoryDB(task_id=task_id, category_id=category_id)
    db.add(association)
    db.commit()
    db.refresh(association)
    return association


def remove_category_from_task(db: Session, task_id: int, category_id: int) -> bool:
    """
    Remove a category association from a task.

    Args:
        db: SQLAlchemy database session
        task_id: The task ID
        category_id: The category ID

    Returns:
        True if removed, False if not found
    """
    result = db.query(TaskCategoryDB).filter(
        TaskCategoryDB.task_id == task_id,
        TaskCategoryDB.category_id == category_id
    ).delete()

    db.commit()
    return result > 0


def get_categories_for_task(db: Session, task_id: int) -> List[CategoryDB]:
    """
    Get all categories associated with a task.

    Args:
        db: SQLAlchemy database session
        task_id: The task ID

    Returns:
        List of categories
    """
    return db.query(CategoryDB).join(
        TaskCategoryDB,
        TaskCategoryDB.category_id == CategoryDB.category_id
    ).filter(
        TaskCategoryDB.task_id == task_id
    ).all()


def get_tasks_by_category(db: Session, category_id: int) -> List[TaskDB]:
    """
    Get all tasks associated with a category.

    Args:
        db: SQLAlchemy database session
        category_id: The category ID

    Returns:
        List of tasks
    """
    return db.query(TaskDB).join(
        TaskCategoryDB,
        TaskCategoryDB.task_id == TaskDB.task_id
    ).filter(
        TaskCategoryDB.category_id == category_id
    ).all()