# routes/admin.py
from datetime import timedelta
from typing import List, Optional

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Path,
    Query,
    Security,
    status,
)
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from ...config import settings
from ...db import get_db
from ...models import AdminDB

# ── نماذج Pydantic ─────────────────────────────────────────────
from ...schemas.admin_schemas.admin import (
    AdminCreate,
    AdminUpdate,
    AdminPasswordChange,
    AdminResponse,
)
from ...schemas.token import Token, RefreshToken

# ── خدمات CRUD للمشرفين ────────────────────────────────────────
from ...services.admin_servies.admin import (
    create_admin,
    update_admin,
    change_admin_password,
    get_admin,
    get_admin_by_username,
    get_admin_by_email,
    get_all_admins,
    delete_admin,
    authenticate_admin,
    update_admin_activity,
)

# ── أدوات الأمان العامّة ───────────────────────────────────────
from ...security import (
    verify_password,
    create_access_token,
    create_refresh_token,
    validate_token,
    get_current_admin,
    get_super_admin,
)

# ── إعدادات الصلاحية ───────────────────────────────────────────
ACCESS_TOKEN_EXPIRE_MINUTES = settings.security.access_token_expire_minutes
REFRESH_TOKEN_EXPIRE_MINUTES = settings.security.refresh_token_expire_minutes

# Create a single router for all admin-related endpoints
router = APIRouter(tags=["admins"])

# -----------------------------------------------------------------
# ███ 1) مسارات المصادقة (تسجيل الدخول + Refresh) ███
# -----------------------------------------------------------------

@router.post("/auth/admin/token", response_model=Token, summary="Admin login")
def login_for_admin_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    admin = authenticate_admin(db, form_data.username, form_data.password)
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect admin username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access = create_access_token(
        data={"sub": admin.username, "admin": True, "fresh": True},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    refresh = create_refresh_token(
        data={"sub": admin.username, "admin": True},
        expires_delta=timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES),
    )
    return {"access_token": access, "refresh_token": refresh, "token_type": "bearer"}

@router.post("/auth/admin/refresh", response_model=Token, summary="Admin token refresh")
def refresh_admin_token(
    form: RefreshToken,
):
    payload = validate_token(token=form.refresh_token)
    if not payload.get("admin", False):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid admin refresh token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    username = payload["sub"]
    access = create_access_token(
        data={"sub": username, "admin": True, "fresh": False},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    refresh = create_refresh_token(
        data={"sub": username, "admin": True},
        expires_delta=timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES),
    )
    return {"access_token": access, "refresh_token": refresh, "token_type": "bearer"}

@router.get("/auth/admin/status", summary="Admin auth health check")
def admin_security_status():
    return {"status": "Admin authentication is healthy 🚀"}

# -----------------------------------------------------------------
# ███ 2) CRUD operations for admins ███
# -----------------------------------------------------------------

@router.post("/admins", response_model=AdminResponse, status_code=201, summary="Create new admin")
def create_admin_endpoint(
    payload: AdminCreate,
    db: Session = Depends(get_db),
    _: dict = Security(get_super_admin),
):
    if get_admin_by_username(db, payload.username):
        raise HTTPException(400, "Username already registered")
    if get_admin_by_email(db, payload.email):
        raise HTTPException(400, "Email already registered")
    return create_admin(db, payload)

@router.get("/admins", response_model=List[AdminResponse], summary="List all admins")
def list_admins(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=1000),
    db: Session = Depends(get_db),
    _: dict = Security(get_current_admin),
):
    return get_all_admins(db, skip, limit)

@router.get("/admins/{admin_id}", response_model=AdminResponse, summary="Get admin by ID")
def read_admin(
    admin_id: int = Path(..., gt=0),
    db: Session = Depends(get_db),
    _: dict = Security(get_current_admin),
):
    admin = get_admin(db, admin_id)
    if not admin:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Admin not found")
    return admin

@router.put("/admins/{admin_id}", response_model=AdminResponse, summary="Update admin")
def update_admin_endpoint(
    admin_id: int = Path(..., gt=0),
    db: Session = Depends(get_db),
    current: dict = Security(get_current_admin),
    payload: AdminUpdate = Body(...),
):
    if admin_id != current["admin_id"] and not current.get("super_admin", False):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not authorized to update other admins")
    updated = update_admin(db, admin_id, payload)
    if not updated:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Admin not found")
    return updated
@router.put("/admins/{admin_id}/password", response_model=AdminResponse, summary="Change admin password")
def change_password(
    admin_id: int = Path(..., gt=0),
    db: Session = Depends(get_db),
    current: dict = Security(get_current_admin),
    payload: AdminPasswordChange = Body(..., embed=True),
):
    if admin_id != current["admin_id"]:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Cannot change another admin's password")
    changed = change_admin_password(db, admin_id, payload)
    if not changed:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Current password incorrect or admin not found")
    return changed@router.patch("/admins/{admin_id}/active", response_model=AdminResponse, summary="Activate/Deactivate admin")
def toggle_admin_active(
    admin_id: int = Path(..., gt=0),
    is_active: bool = Query(...),
    db: Session = Depends(get_db),
    current: dict = Security(get_super_admin),
):
    if admin_id == current.get("admin_id") and not is_active:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot deactivate your own account")
    updated = update_admin_activity(db, admin_id, is_active)
    if not updated:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Admin not found")
    return updated

@router.delete("/admins/{admin_id}", status_code=204, summary="Delete admin")
def delete_admin_endpoint(
    admin_id: int = Path(..., gt=0),
    db: Session = Depends(get_db),
    current: dict = Security(get_super_admin),
):
    if admin_id == current["admin_id"]:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot delete your own account")
    if not delete_admin(db, admin_id):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Admin not found")
    return None

# -----------------------------------------------------------------
# ███ 3) Health-check ███
# -----------------------------------------------------------------
@router.get("/admins/security-status", summary="Health-check")
def admins_security_status():
    return {"status": "Admin routes are active 🚀"}