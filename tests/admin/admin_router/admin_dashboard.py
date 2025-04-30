# routes/admin_dashboard.py

from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from typing import List

# Service functions for admin dashboard management
from final_project.services.admin_servies.admin_dashboard import (
    create_dashboard,
    update_dashboard,
    get_dashboard,
    get_admin_dashboards,
    get_default_dashboard,
    add_widget_to_dashboard,
    remove_widget_from_dashboard,
    delete_dashboard
)

# Admin verification service
from final_project.services.admin_servies.admin import get_admin

# Schemas for request and response validation
from final_project.schemas.admin_schemas.admin_dashboard import (
    AdminDashboardCreate,
    AdminDashboardUpdate,
    AdminDashboardResponse,
    WidgetCreate
)

# Database dependency
from final_project.db import get_db

router = APIRouter(
    prefix="/admin-dashboard",
    tags=["Admin Dashboards"]
)

# Create a new admin dashboard
@router.post("/", response_model=AdminDashboardResponse)
def create_new_dashboard(
    dashboard_data: AdminDashboardCreate,
    db: Session = Depends(get_db)
):
    # Verify the admin exists before creating a dashboard
    admin = get_admin(db, dashboard_data.admin_id)
    if not admin:
        raise HTTPException(status_code=404, detail="Admin not found")

    return create_dashboard(db, dashboard_data)

# Get a dashboard by its ID
@router.get("/{dashboard_id}", response_model=AdminDashboardResponse)
def get_dashboard_by_id(
    dashboard_id: int = Path(..., description="The ID of the dashboard"),
    db: Session = Depends(get_db)
):
    dashboard = get_dashboard(db, dashboard_id)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")

    return dashboard

# Get all dashboards associated with a specific admin
@router.get("/admin/{admin_id}", response_model=List[AdminDashboardResponse])
def get_dashboards_for_admin(
    admin_id: int = Path(..., description="The ID of the admin"),
    db: Session = Depends(get_db)
):
    # Verify the admin exists
    admin = get_admin(db, admin_id)
    if not admin:
        raise HTTPException(status_code=404, detail="Admin not found")

    return get_admin_dashboards(db, admin_id)

# Get the default dashboard for a specific admin
@router.get("/admin/{admin_id}/default", response_model=AdminDashboardResponse)
def get_admin_default_dashboard(
    admin_id: int = Path(..., description="The ID of the admin"),
    db: Session = Depends(get_db)
):
    # Verify the admin exists
    admin = get_admin(db, admin_id)
    if not admin:
        raise HTTPException(status_code=404, detail="Admin not found")

    dashboard = get_default_dashboard(db, admin_id)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Default dashboard not found")

    return dashboard

# Update an existing dashboard
@router.put("/{dashboard_id}", response_model=AdminDashboardResponse)
def update_existing_dashboard(
    dashboard_data: AdminDashboardUpdate,
    dashboard_id: int = Path(..., description="The ID of the dashboard to update"),
    db: Session = Depends(get_db)
):
    # Check if dashboard exists
    existing_dashboard = get_dashboard(db, dashboard_id)
    if not existing_dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")

    return update_dashboard(db, dashboard_id, dashboard_data)

# Add a widget to an existing dashboard
@router.post("/{dashboard_id}/widgets", response_model=AdminDashboardResponse)
def add_widget(
    widget_data: WidgetCreate,
    dashboard_id: int = Path(..., description="The ID of the dashboard"),
    db: Session = Depends(get_db)
):
    # Check if dashboard exists
    dashboard = get_dashboard(db, dashboard_id)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")

    return add_widget_to_dashboard(db, dashboard_id, widget_data.dict())

# Remove a widget from a dashboard by index
@router.delete("/{dashboard_id}/widgets/{widget_index}", response_model=AdminDashboardResponse)
def remove_widget(
    dashboard_id: int = Path(..., description="The ID of the dashboard"),
    widget_index: int = Path(..., description="The index of the widget to remove"),
    db: Session = Depends(get_db)
):
    dashboard = get_dashboard(db, dashboard_id)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")

    updated_dashboard = remove_widget_from_dashboard(db, dashboard_id, widget_index)
    if not updated_dashboard:
        raise HTTPException(status_code=404, detail="Widget not found at specified index")

    return updated_dashboard

# Delete an existing dashboard
@router.delete("/{dashboard_id}")
def delete_existing_dashboard(
    dashboard_id: int = Path(..., description="The ID of the dashboard to delete"),
    db: Session = Depends(get_db)
):
    dashboard = get_dashboard(db, dashboard_id)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")

    result = delete_dashboard(db, dashboard_id)
    if not result:
        raise HTTPException(status_code=500, detail="Failed to delete dashboard")

    return {"message": "Dashboard deleted successfully"}
