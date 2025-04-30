from fastapi import APIRouter, Depends

from final_project.security import get_current_active_user  # ✅ استيراد الديبيندنسي الجديد
from final_project.models.user import UserDB  # ✅ استيراد الـ ORM model
from final_project.schemas.user import UserResponse  # ✅ استيراد الـ Response schema

router = APIRouter()

@router.get("/profile", response_model=UserResponse)
async def my_profile(current_user: UserDB = Depends(get_current_active_user)):  # ✅ تغيير الديبيندنسي
    return current_user
