# routes/admin.py

from fastapi import APIRouter, Depends, HTTPException, Path, Query, Security
from sqlalchemy.orm import Session
from typing import List

# Database dependency
from final_project.db import get_db

# Schemas for validation
from final_project.schemas.admin_schemas.admin import (
    AdminCreate, AdminUpdate, AdminResponse, AdminPasswordChange
)

# Services for admin CRUD operations
from final_project.services.admin_servies.admin import (
    create_admin,
    update_admin,
    change_admin_password,
    get_admin,
    get_admin_by_username,
    get_admin_by_email,
    get_all_admins,
    delete_admin,
    update_admin_activity
)

# Security dependencies for authorization
from final_project.security import get_current_admin, get_super_admin

router = APIRouter(prefix="/admins", tags=["admins"])

# Create a new admin account (Super Admin only)
@router.post("/", response_model=AdminResponse, status_code=201)
def create_admin_endpoint(
    admin: AdminCreate, 
    db: Session = Depends(get_db),
    current_admin: dict = Security(get_super_admin)
):
    # Check if username exists
    if get_admin_by_username(db, admin.username):
        raise HTTPException(status_code=400, detail="Username already registered")

    # Check if email exists
    if get_admin_by_email(db, admin.email):
        raise HTTPException(status_code=400, detail="Email already registered")

    return create_admin(db=db, admin_data=admin)

# Retrieve a list of all admins (Accessible by any admin)
@router.get("/", response_model=List[AdminResponse])
def read_admins(
    skip: int = Query(0, description="Skip records"),
    limit: int = Query(100, description="Limit number of records"),
    db: Session = Depends(get_db),
    current_admin: dict = Security(get_current_admin)
):
    return get_all_admins(db=db, skip=skip, limit=limit)

# Retrieve specific admin by ID
@router.get("/{admin_id}", response_model=AdminResponse)
def read_admin(
    admin_id: int = Path(..., description="ID of admin to retrieve"),
    db: Session = Depends(get_db),
    current_admin: dict = Security(get_current_admin)
):
    db_admin = get_admin(db=db, admin_id=admin_id)
    if db_admin is None:
        raise HTTPException(status_code=404, detail="Admin not found")
    return db_admin

# Update admin information (self-update or Super Admin)
@router.put("/{admin_id}", response_model=AdminResponse)
def update_admin_endpoint(
    admin_id: int = Path(..., description="ID of admin to update"),
    admin_data: AdminUpdate = ...,
    db: Session = Depends(get_db),
    current_admin: dict = Security(get_current_admin)
):
    if admin_id != current_admin["admin_id"] and not current_admin.get("super_admin", False):
        raise HTTPException(status_code=403, detail="Not authorized to update other admins")

    updated_admin = update_admin(db=db, admin_id=admin_id, admin_data=admin_data)
    if updated_admin is None:
        raise HTTPException(status_code=404, detail="Admin not found")
    return updated_admin

# Change admin password (self only)
@router.put("/{admin_id}/password", response_model=AdminResponse)
def change_password(
    admin_id: int = Path(..., description="ID of admin to change password"),
    password_data: AdminPasswordChange = ...,
    db: Session = Depends(get_db),
    current_admin: dict = Security(get_current_admin)
):
    if admin_id != current_admin["admin_id"]:
        raise HTTPException(status_code=403, detail="Not authorized to change other admin's password")

    changed_admin = change_admin_password(db=db, admin_id=admin_id, password_data=password_data)
    if changed_admin is None:
        raise HTTPException(status_code=400, detail="Current password incorrect or admin not found")
    return changed_admin

# Activate or deactivate admin account (Super Admin only)
@router.patch("/{admin_id}/active", response_model=AdminResponse)
def update_admin_active_status(
    admin_id: int = Path(..., description="ID of admin to update status"),
    is_active: bool = Query(..., description="Activate or deactivate admin"),
    db: Session = Depends(get_db),
    current_admin: dict = Security(get_super_admin)
):
    if admin_id == current_admin["admin_id"] and not is_active:
        raise HTTPException(status_code=400, detail="Cannot deactivate your own account")

    updated_admin = update_admin_activity(db=db, admin_id=admin_id, is_active=is_active)
    if updated_admin is None:
        raise HTTPException(status_code=404, detail="Admin not found")
    return updated_admin

# Delete an admin account (Super Admin only)
@router.delete("/{admin_id}")
def delete_admin_endpoint(
    admin_id: int = Path(..., description="ID of admin to delete"),
    db: Session = Depends(get_db),
    current_admin: dict = Security(get_super_admin)
):
    if admin_id == current_admin["admin_id"]:
        raise HTTPException(status_code=400, detail="Cannot delete your own account")

    success = delete_admin(db=db, admin_id=admin_id)
    if not success:
        raise HTTPException(status_code=404, detail="Admin not found")
    return {"message": "Admin successfully deleted"}
