from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.services.default_habit import (
    create_default_habit, 
    update_default_habit, 
    get_default_habit,
    get_default_habits, 
    update_adoption_rate,
    delete_default_habit
)
from final_project.schemas.default_habit import DefaultHabitCreate, DefaultHabitUpdate, DefaultHabitResponse
from final_project.models.user import UserDB
from final_project.models.category import CategoryDB
from final_project.models.habit import HabitDB
from final_project.db import get_db

router = APIRouter(prefix="/default-habits", tags=["Default Habits"])

# 🔹 إنشاء عادة افتراضية جديدة
@router.post("/", response_model=DefaultHabitResponse)
def create_habit(
    habit_data: DefaultHabitCreate,
    db: Session = Depends(get_db)
):
    """
    Create a new default habit.
    """
    if habit_data.created_by:
        user = db.query(UserDB).filter(UserDB.user_id == habit_data.created_by).first()
        if not user or not user.superuser:
            raise HTTPException(status_code=404, detail="Admin (superuser) not found")

    if habit_data.category_id:
        category = db.query(CategoryDB).filter(CategoryDB.category_id == habit_data.category_id).first()
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")

    return create_default_habit(db, habit_data)

# 🔹 استرجاع عادة افتراضية واحدة
@router.get("/{default_habit_id}", response_model=DefaultHabitResponse)
def get_habit(
    default_habit_id: int = Path(..., description="The ID of the default habit"),
    db: Session = Depends(get_db)
):
    habit = get_default_habit(db, default_habit_id)
    if not habit:
        raise HTTPException(status_code=404, detail="Default habit not found")
    return habit

# 🔹 استرجاع جميع العادات الافتراضية مع فلترة اختيارية
@router.get("/", response_model=List[DefaultHabitResponse])
def list_habits(
    active_only: bool = Query(True, description="If true, return only active default habits"),
    category_id: Optional[int] = Query(None, description="Filter by category ID"),
    ai_recommended: Optional[bool] = Query(None, description="Filter by AI recommendation status"),
    db: Session = Depends(get_db)
):
    return get_default_habits(db, active_only, category_id, ai_recommended)

# 🔹 تحديث عادة افتراضية
@router.put("/{default_habit_id}", response_model=DefaultHabitResponse)
def update_habit(
    habit_data: DefaultHabitUpdate,
    default_habit_id: int = Path(..., description="The ID of the default habit to update"),
    db: Session = Depends(get_db)
):
    habit = get_default_habit(db, default_habit_id)
    if not habit:
        raise HTTPException(status_code=404, detail="Default habit not found")

    if habit_data.category_id:
        category = db.query(CategoryDB).filter(CategoryDB.category_id == habit_data.category_id).first()
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")

    return update_default_habit(db, default_habit_id, habit_data)

# 🔹 حساب وتحديث معدل التبني (adoption rate)
@router.post("/{default_habit_id}/adoption-rate", response_model=float)
def calculate_adoption_rate(
    default_habit_id: int = Path(..., description="The ID of the default habit"),
    db: Session = Depends(get_db)
):
    habit = get_default_habit(db, default_habit_id)
    if not habit:
        raise HTTPException(status_code=404, detail="Default habit not found")

    return update_adoption_rate(db, default_habit_id)

# 🔹 حذف عادة افتراضية
@router.delete("/{default_habit_id}")
def remove_habit(
    default_habit_id: int = Path(..., description="The ID of the default habit to delete"),
    db: Session = Depends(get_db)
):
    result = delete_default_habit(db, default_habit_id)
    if not result:
        raise HTTPException(status_code=404, detail="Default habit not found")

    return {"message": "Default habit deleted successfully"}

# 🔹 إضافة العادات الافتراضية إلى المستخدم (مع إنشاء نسخ جديدة لكل مستخدم)
@router.post("/users/{username}/habits")
def add_habits_to_user(
    username: str,
    habit_ids: List[int],  # List of default habit IDs
    db: Session = Depends(get_db)
):
    user = db.query(UserDB).filter(UserDB.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    default_habits = db.query(HabitDB).filter(HabitDB.habit_id.in_(habit_ids)).all()
    if not default_habits:
        raise HTTPException(status_code=404, detail="Default habits not found")

    for default_habit in default_habits:
        new_habit = HabitDB(
            title=default_habit.title,
            description=default_habit.description,
            goal=default_habit.goal,
            period=default_habit.period,
            reminder=default_habit.reminder,
            color=default_habit.color,
            ai_recommended=default_habit.ai_recommended,
            category_id=default_habit.category_id,
            created_by=user.user_id,
            is_default=False  # Mark it as user's custom habit, not default
        )
        db.add(new_habit)
        user.habits.append(new_habit)  # Assuming UserDB has a relationship: habits = relationship("HabitDB", ...)

    db.commit()

    return {"message": "Habits successfully added to user."}
